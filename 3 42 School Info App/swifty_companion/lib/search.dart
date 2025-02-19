import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  bool _hasText = false;
  final _storage = FlutterSecureStorage();
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _hasText = _controller.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void printErrorMessage(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Align(
            child: Text(
              msg,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red, fontSize: 18),
            ),
          ),
          backgroundColor: Colors.white,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  // Get the stored token, or request a new one if expired
  Future<String?> getAccessToken() async {
    String? token = await _storage.read(key: "access_token");
    String? expiration = await _storage.read(key: "token_expiration");

    if (token != null && expiration != null) {
      DateTime expirationTime = DateTime.parse(expiration);

      if (DateTime.now().isBefore(expirationTime)) {
        return token;
      }
    }

    return await fetchNewToken();
  }

  // Request a new token and store it securely
  Future<String?> fetchNewToken() async {
    try {
      final response = await http.post(
        Uri.parse(dotenv.get('42TOKENURL')),
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: {
          "grant_type": "client_credentials",
          "client_id": dotenv.get('42UID'),
          "client_secret": dotenv.get('42SECRET'),
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String accessToken = data["access_token"];
        int expiresIn = data["expires_in"];

        // Calculate expiration time
        DateTime expirationTime =
            DateTime.now().add(Duration(seconds: expiresIn));

        // Store the token and its expiration securely
        await _storage.write(key: "access_token", value: accessToken);
        await _storage.write(
            key: "token_expiration", value: expirationTime.toIso8601String());

        return accessToken;
      } else {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        printErrorMessage("${response.statusCode}: ${responseData["error"]}");
        return null;
      }
    } catch (e) {
      printErrorMessage(
          "Error fetching token: Please connect to the interent and try again");
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUserData(String login) async {
    try {
      String? accessToken = await getAccessToken();

      if (accessToken == null) {
        return null;
      }

      final url = dotenv.get('42USERURL') + login;

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $accessToken",
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 404) {
        printErrorMessage("User not found.");
        return null;
      } else {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        printErrorMessage(responseData["error"]);
        return null;
      }
    } catch (e) {
      printErrorMessage("Error: No internet connection.");
      return null;
    }
  }

  void navigateToProfile() async {
    if (_controller.text == "") {
      return;
    }

    Map<String, dynamic>? data = await getUserData(_controller.text);

    if (mounted && data != null) {
      Navigator.pushNamed(context, '/profile', arguments: data);
    }
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: MediaQuery.of(context).viewInsets.bottom > 0
                          ? MediaQuery.of(context).size.height * 0.08
                          : MediaQuery.of(context).size.height * 0.12,
                    ),
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/42_Logo.png',
                          height: MediaQuery.of(context).size.width * 0.15,
                          width: MediaQuery.of(context).size.width * 0.15,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          textAlign: TextAlign.center,
                          "Enter a login to show data:",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                  TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      labelText: 'Login',
                      filled: true,
                      fillColor: Colors.white,
                      suffixIcon: _hasText
                          ? IconButton(
                              icon: Icon(Icons.clear),
                              onPressed: () {
                                _controller.clear();
                                setState(() {
                                  _hasText = false;
                                });
                              },
                            )
                          : null,
                    ),
                    autocorrect: false,
                    maxLength: 15,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty<Color>.fromMap(
                          <WidgetStatesConstraint, Color>{
                            WidgetState.pressed | WidgetState.hovered:
                                Colors.indigo,
                            WidgetState.any:
                                _hasText ? Colors.white : Colors.white70,
                          },
                        ),
                      ),
                      onPressed: navigateToProfile,
                      child: Text("Search"),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
