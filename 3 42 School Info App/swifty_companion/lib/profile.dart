import 'package:flutter/material.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key, required this.userData});

  final Map<String, dynamic> userData;

  List<Map<String, dynamic>> buildProjectsList() {
    var projects = userData['projects_users'];
    List<Map<String, dynamic>> comletedProjects = [];

    for (var i = 0; i < userData['projects_users'].length; i++) {
      if (projects[i]['status'] == "finished") {
        comletedProjects.add({
          'name': projects[i]['project']['name'],
          'mark': projects[i]['final_mark'],
        });
      }
    }

    return comletedProjects;
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> skills = userData['cursus_users'][1]['skills'] ??
        userData['cursus_users'][0]['skills'];
    List<Map<String, dynamic>> projects = buildProjectsList();

    return Scaffold(
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
              padding: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.height * 0.04,
                horizontal: MediaQuery.of(context).size.width * 0.05,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Profile picture and name
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 40,
                          backgroundImage: userData['image']['link'] != null
                              ? NetworkImage(userData['image']['link'])
                              : const AssetImage("assets/default-avatar.png")
                                  as ImageProvider,
                          backgroundColor: Colors.grey[300],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userData['login'],
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              userData['email'],
                              style: TextStyle(
                                  color: Colors.cyanAccent, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Data - lvl, wallet, eval points
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text("Lvl ${userData['cursus_users'][1]['level']}",
                            style: TextStyle(
                                color: Colors.greenAccent, fontSize: 15)),
                        Text("Wallet ${userData['wallet']}₳",
                            style: TextStyle(
                                color: Colors.greenAccent, fontSize: 15)),
                        Text("Eval. points ${userData['correction_point']}",
                            style: TextStyle(
                                color: Colors.greenAccent, fontSize: 15)),
                      ],
                    ),
                  ),

                  // Projects
                  Card.filled(
                    color: Colors.white.withAlpha(80),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            "Completed Projects",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.25,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: projects.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.7,
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Text(
                                        "${projects[index]['name']}",
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    "${projects[index]['mark']}",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              );
                            },
                          ),
                        )
                      ],
                    ),
                  ),

                  // Skills
                  Card.filled(
                    color: Colors.white.withAlpha(80),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            "Skills",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.25,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(0),
                            itemCount: skills.length,
                            itemBuilder: (BuildContext context, int index) {
                              double level = skills[index]["level"];
                              int percentage =
                                  ((level - level.floor()) * 100).round();

                              return ListTile(
                                dense: true,
                                visualDensity: VisualDensity.compact,
                                title: Text(
                                  skills[index]['name'],
                                  style: TextStyle(fontSize: 16),
                                ),
                                subtitle: Text(
                                    "Level: ${level.toStringAsFixed(2)} ($percentage%)"),
                              );
                            },
                          ),
                        )
                      ],
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
