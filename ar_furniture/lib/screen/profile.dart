import 'package:firebase_database/firebase_database.dart';
import 'login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constant/color.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import '../object/user.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Users user = Users(
    phoneNumber: "",
    name: "",
    email: "",
    address: "",
    avatar: "",
    coverPhoto: "",
  );
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getProfile();
  }

  void getProfile() {
    String phone = FirebaseAuth.instance.currentUser!.phoneNumber.toString();
    var userProfile = FirebaseDatabase.instance
        .ref()
        .child('Users')
        .child(phone);

    userProfile.get().then((DataSnapshot snapshot) {
      if (snapshot.value != null) {
        setState(() {
          user = Users(
            phoneNumber: phone,
            name: snapshot.child('name').value as String,
            email: snapshot.child('email').value as String,
            address: snapshot.child('address').value as String,
            avatar: snapshot.child('avatar').value as String,
            coverPhoto: snapshot.child('coverPhoto').value as String,
          );
          nameController.text = user.name;
          emailController.text = user.email;
          addressController.text = user.address;
        });
      }
    });
  }

  // function to display dialog to select update avatar or cover photo
  void selectUpdate() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: const Text('Choose avatar from gallery'),
                  onTap: () {
                    updateAvatar('Avatars', 'avatar');
                    Navigator.of(context).pop();
                  },
                ),
                const Padding(padding: EdgeInsets.all(8.0)),
                GestureDetector(
                  child: const Text('Choose cover photo from gallery'),
                  onTap: () {
                    updateAvatar('Covers', 'coverPhoto');
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // function update avatar image from gallery to firebase storage and realtime database
  void updateAvatar(String folder, String child) async {
    final storage = FirebaseStorage.instance;
    final picker = ImagePicker();
    XFile? image;
    // Check permission
    await Permission.photos.request();
    var permissionStatus = await Permission.photos.status;
    if (permissionStatus.isGranted) {
      // Select image
      image = await picker.pickImage(source: ImageSource.gallery);
      var file = File(image?.path as String);
      if (image != null) {
        // Upload to firebase
        var snapshot = await storage
            .ref()
            .child('$folder/${user.phoneNumber}')
            .putFile(file)
            .whenComplete(() => null);
        var downloadUrl = await snapshot.ref.getDownloadURL();
        // Update avatar image to realtime database
        var userProfile = FirebaseDatabase.instance
            .ref()
            .child('Users')
            .child(user.phoneNumber);
        userProfile.child(child).set(downloadUrl).then((value) => {
              setState(() {
                if (child == 'avatar') {
                  user.avatar = downloadUrl;
                } else {
                  user.coverPhoto = downloadUrl;
                }
              })
            });
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: child == 'avatar'
                ? const  Text('Avatar image updated')
                :const  Text('Cover photo updated'),
            duration:const  Duration(milliseconds: 500),
          ),
        );
      } else {
        print('No path received');
      }
    } else {
      print('Grant permission and try again');
    }
  }

  // function open dialog to edit profile user
  void openEditProfileDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Name',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Email',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Address',
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                if (nameController.text.isEmpty ||
                    emailController.text.isEmpty ||
                    addressController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill all fields'),
                    ),
                  );
                  return;
                }
                if (!emailController.text.contains('@')) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Email is invalid'),
                    ),
                  );
                  return;
                }
                final userProfile =
                    FirebaseDatabase.instance.ref().child('Users').child(user.phoneNumber);
                userProfile.child('address').set(addressController.text);
                userProfile.child('email').set(emailController.text);
                userProfile.child('name').set(nameController.text);
                getProfile();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Cover image and avatar
            SizedBox(
              height: 250,
              child: Stack(
                children: [
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: user.coverPhoto == ""
                            ? const AssetImage('assets/images/cover.jpg')
                            : NetworkImage(user.coverPhoto) as ImageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: MediaQuery.of(context).size.width / 2 - 60,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 5,
                        ),
                        image: DecorationImage(
                          image: user.avatar == ""
                              ? const AssetImage('assets/images/avatar.jpg')
                              : NetworkImage(user.avatar) as ImageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 5,
                    left: MediaQuery.of(context).size.width / 2 + 20,
                    child: GestureDetector(
                      onTap: () {
                        selectUpdate();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: primaryColor,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            // Name
            const SizedBox(height: 10),
            Text(
              user.name == "" ? "Your Name" : user.name,
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            // Profile actions
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          '10',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Posts',
                          style: TextStyle(
                            fontSize: 15,
                            color: inputColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          '100',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Followers',
                          style: TextStyle(
                            fontSize: 15,
                            color: inputColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          '50',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Following',
                          style: TextStyle(
                            fontSize: 15,
                            color: inputColor,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),
            // List information include phone, email, address, etc.
            Container(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(children: [
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const SizedBox(width: 20),
                        const Icon(
                          Icons.phone,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 20),
                        Text(
                          user.phoneNumber,
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const Divider(
                      color: inputColor,
                      indent: 20,
                      endIndent: 20,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const SizedBox(width: 20),
                        const Icon(
                          Icons.email,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 20),
                        Text(
                          user.email == "" ? "Your Email" : user.email,
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const Divider(
                      color: inputColor,
                      indent: 20,
                      endIndent: 20,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const SizedBox(width: 20),
                        const Icon(
                          Icons.location_on,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 20),
                        Text(
                          user.address == "" ? "Your Address" : user.address,
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ]),
                )),
            // Button edit profile
            Container(
                padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
                child: GestureDetector(
                  onTap: () {
                    openEditProfileDialog();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Column(children: [
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.edit,
                            color: Colors.black,
                          ),
                          SizedBox(width: 20),
                          Text(
                            'Edit Profile',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                    ]),
                  ),
                )),
            // Button logout
            Container(
                padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
                child: GestureDetector(
                  onTap: () {
                    FirebaseAuth.instance.signOut();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Column(children: [
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.logout,
                            color: Colors.white,
                          ),
                          SizedBox(width: 20),
                          Text(
                            'Logout',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                    ]),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
