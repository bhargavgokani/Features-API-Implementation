import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'locationScreen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController latController = TextEditingController();
  final TextEditingController lngController = TextEditingController();
  File? _imgFile;
  String? _imgUrl;

  Future<void> _deleteUser(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('user').doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User deleted successfully'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to delete user'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDeleteConfirmation(BuildContext context, DocumentSnapshot userDoc) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Confirmation'),
          content: const Text('Are you sure you want to delete this user?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteUser(userDoc.id);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> addDataToFireStore() async {
    if (_imgFile != null) {
      final url = Uri.parse('https://api.cloudinary.com/v1_1/dcnji1kqb/upload');
      final req = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = 'p2bpstly'
        ..files.add(await http.MultipartFile.fromPath('file', _imgFile!.path));

      final response = await req.send();
      if (response.statusCode == 200) {
        final resData = await response.stream.bytesToString();
        final jsonMap = jsonDecode(resData);
        setState(() {
          _imgUrl = jsonMap['url'];
        });
      }
    }
    Map<String, dynamic> map = {
      "first name": firstNameController.text,
      "last name": lastNameController.text,
      "mobile no": mobileController.text,
      "email": emailController.text,
      "address": addressController.text,
      "lat": latController.text,
      "long": lngController.text,
      'img': _imgUrl
    };
    CollectionReference collectionReference =
        FirebaseFirestore.instance.collection('user');
    collectionReference.add(map);
  }

  void _showUserDetails(BuildContext context, Map<String, dynamic> userData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${userData["first name"]} ${userData["last name"]}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (userData['img'] != null)
              Image.network(
                userData['img'],
                height: 150,
                width: 150,
              ),
            Text('Mobile: ${userData["mobile no"]}'),
            Text('Email: ${userData["email"]}'),
            Text('Address: ${userData["address"]}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserMapScreen(
                      lat: double.parse(userData['lat']),
                      lng: double.parse(userData['long'])),
                ),
              );
            },
            child: const Text('Show location'),
          ),
        ],
      ),
    );
  }

  void _showPopupMenu(
      BuildContext context, GlobalKey key, DocumentSnapshot userDoc) async {
    final RenderBox renderBox =
        key.currentContext?.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);

    final userData = userDoc.data() as Map<String, dynamic>;
    await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy,
        offset.dx + renderBox.size.width,
        offset.dy + renderBox.size.height,
      ),
      items: [
        const PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit, color: Colors.green),
                SizedBox(width: 8),
                Text('Edit'),
              ],
            )),
        const PopupMenuItem(
          value: 'view',
          child: Row(
            children: [
              Icon(Icons.visibility, color: Colors.blue),
              SizedBox(width: 8),
              Text('View Details'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, color: Colors.red),
              SizedBox(width: 8),
              Text('Delete'),
            ],
          ),
        ),
      ],
    ).then((selectedValue) async {
      if (selectedValue == 'view') {
        _showUserDetails(context, userData);
      } else if (selectedValue == 'edit') {
        _showEditForm(context, userDoc);
      } else if (selectedValue == 'delete') {
        _showDeleteConfirmation(context, userDoc);
        // await _deleteUser(userDoc.id);
      }
    });
  }

  void _showUserForm(BuildContext context,
      {bool isEditing = false, String? userId}) {
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title:
                  Text(isEditing ? 'Edit User Details' : 'Enter User Details'),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: firstNameController,
                        decoration: const InputDecoration(
                            labelText: 'First Name',
                            border: OutlineInputBorder()),
                        validator: (value) =>
                            value!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: lastNameController,
                        decoration: const InputDecoration(
                            labelText: 'Last Name',
                            border: OutlineInputBorder()),
                        validator: (value) =>
                            value!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: mobileController,
                        decoration: const InputDecoration(
                            labelText: 'Mobile', border: OutlineInputBorder()),
                        keyboardType: TextInputType.phone,
                        validator: (value) => value!.isEmpty
                            ? 'Required'
                            : value.length != 10
                                ? 'Enter valid mobile number'
                                : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: emailController,
                        decoration: const InputDecoration(
                            labelText: 'Email', border: OutlineInputBorder()),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) =>
                            value!.isEmpty || !value.contains('@')
                                ? 'Enter valid email'
                                : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: addressController,
                        decoration: const InputDecoration(
                            labelText: 'Address', border: OutlineInputBorder()),
                        validator: (value) =>
                            value!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: latController,
                              decoration: const InputDecoration(
                                  labelText: 'Latitude',
                                  border: OutlineInputBorder()),
                              keyboardType: TextInputType.number,
                              validator: (value) =>
                                  value!.isEmpty ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: lngController,
                              decoration: const InputDecoration(
                                  labelText: 'Longitude',
                                  border: OutlineInputBorder()),
                              keyboardType: TextInputType.number,
                              validator: (value) =>
                                  value!.isEmpty ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              showModalBottomSheet(
                                context: context,
                                builder: (context) => Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      leading: const Icon(Icons.camera_alt),
                                      title: const Text('Take Photo'),
                                      onTap: () async {
                                        Navigator.pop(context);
                                        ImagePicker imagePicker = ImagePicker();
                                        XFile? file =
                                            await imagePicker.pickImage(
                                                source: ImageSource.camera);
                                        setState(() {
                                          if (file != null) {
                                            _imgFile = File(file.path);
                                          }
                                        });
                                      },
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.photo),
                                      title: const Text('Choose from Gallery'),
                                      onTap: () async {
                                        Navigator.pop(context);
                                        ImagePicker imagePicker = ImagePicker();
                                        XFile? file =
                                            await imagePicker.pickImage(
                                                source: ImageSource.gallery);
                                        setState(() {
                                          if (file != null) {
                                            _imgFile = File(file.path);
                                          }
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Icon(Icons.camera_alt_outlined),
                                Text(
                                  'Upload Image',
                                  style: TextStyle(color: Color(0xFF3F5769)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          if (_imgFile != null)
                            SizedBox(
                              width: 50,
                              height: 50,
                              child: Image.file(
                                _imgFile!,
                                fit: BoxFit.cover,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    firstNameController.clear();
                    lastNameController.clear();
                    mobileController.clear();
                    emailController.clear();
                    addressController.clear();
                    latController.clear();
                    lngController.clear();
                    _imgUrl = "";
                    _imgFile = null;
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Color(0xFF3F5769)),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      if (isEditing && userId != null && !isLoading) {
                        setState(() {
                          isLoading = true;
                        });
                        await _updateUser(userId);
                        setState(() {
                          isLoading = false;
                        });
                        Navigator.of(context).pop();
                        firstNameController.clear();
                        lastNameController.clear();
                        mobileController.clear();
                        emailController.clear();
                        addressController.clear();
                        latController.clear();
                        lngController.clear();
                        _imgUrl = "";
                        _imgFile = null;
                      } else {
                        if (!isLoading) {
                          setState(() {
                            isLoading = true;
                          });
                          await addDataToFireStore();
                          setState(() {
                            isLoading = false;
                          });
                          Navigator.of(context).pop();
                          firstNameController.clear();
                          lastNameController.clear();
                          mobileController.clear();
                          emailController.clear();
                          addressController.clear();
                          latController.clear();
                          lngController.clear();
                          _imgUrl = "";
                          _imgFile = null;
                        }
                      }
                    }
                  },
                  child: isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.black,
                          strokeWidth: 2,
                        )
                      : const Text(
                          'Submit',
                          style: TextStyle(color: Color(0xFF3F5769)),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditForm(BuildContext context, DocumentSnapshot userDoc) {
    final userData = userDoc.data() as Map<String, dynamic>;

    // Pre-fill controllers
    firstNameController.text = userData['first name'];
    lastNameController.text = userData['last name'];
    mobileController.text = userData['mobile no'];
    emailController.text = userData['email'];
    addressController.text = userData['address'];
    latController.text = userData['lat'];
    lngController.text = userData['long'];
    _imgUrl = userData['img'];
    _showUserForm(context, isEditing: true, userId: userDoc.id);
  }

  Future<void> _updateUser(String userId) async {
    if (_imgFile != null) {
      print('inside img not null');
      // Upload new image to Cloudinary
      final url = Uri.parse('https://api.cloudinary.com/v1_1/dcnji1kqb/upload');
      final req = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = 'p2bpstly'
        ..files.add(await http.MultipartFile.fromPath('file', _imgFile!.path));

      final response = await req.send();
      if (response.statusCode == 200) {
        final resData = await response.stream.bytesToString();
        final jsonMap = jsonDecode(resData);
        setState(() {
          _imgUrl = jsonMap['url'];
        });
      }
    }
    // print('img part completed ......... $_imgUrl');
    print('Updating Firestore with the following data:');
    print({
      "first name": firstNameController.text,
      "last name": lastNameController.text,
      "mobile no": mobileController.text,
      "email": emailController.text,
      "address": addressController.text,
      "lat": latController.text,
      "long": lngController.text,
      "img": _imgUrl,
    });
    await FirebaseFirestore.instance.collection('user').doc(userId).update({
      "first name": firstNameController.text,
      "last name": lastNameController.text,
      FieldPath.fromString("mobile no"): mobileController.text,
      "email": emailController.text,
      "address": addressController.text,
      "lat": latController.text,
      "long": lngController.text,
      'img': _imgUrl
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User updated successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_outlined,
            color: Colors.white,
          ),
        ),
        title: const Text(
          "Users",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF3F5769),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showUserForm(context),
        backgroundColor: const Color(0xFF3F5769),
        foregroundColor: Colors.white,
        child: const Icon(
          Icons.add,
          size: 30,
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('user').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final users = snapshot.data!.docs;
          List<GlobalKey> keys =
              List.generate(users.length, (index) => GlobalKey());

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final userData = users[index].data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  leading: userData['img'] != null
                      ? Image.network(userData['img'], width: 50, height: 50)
                      : const Icon(Icons.person),
                  title: Text(
                      '${userData["first name"]} ${userData["last name"]}'),
                  subtitle: Text(
                    'Email: ${userData["email"]}',
                    overflow:
                        TextOverflow.ellipsis, // Add ellipsis to truncate text
                    maxLines: 1, // Restrict to a single line
                  ),
                  trailing: IconButton(
                    key: keys[index],
                    icon: const Icon(Icons.more_vert),
                    onPressed: () =>
                        _showPopupMenu(context, keys[index], users[index]),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
