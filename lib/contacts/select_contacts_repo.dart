import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fast_contacts/fast_contacts.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

  DocumentSnapshot? ss;

class ContactList extends StatefulWidget {
  @override
  State<ContactList> createState() => _ContactListState();
}

class _ContactListState extends State<ContactList> {

  FirebaseFirestore firestore = FirebaseFirestore.instance;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(onPressed: (){}, icon: Icon(Icons.person))
        ],
        title:const Text('Contact List'),
      ),
      body: Container(
        color: Colors.amber,
        height: double.infinity,
        child: FutureBuilder(
          future: getContact(),
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.data == null) {
              return const Center(
                child: SizedBox(height: 50, child: CircularProgressIndicator()),
              );
            }
            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                Contact contact = snapshot.data[index];
                return InkWell(
                  onTap: () => selectContact(contact.phones[0] , context),
                  child: ListTile(
                    leading: const CircleAvatar(
                      radius: 20,
                      child: Icon(Icons.person),
                    ),
                    title: Text(contact.displayName),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                           contact.phones[0],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<List<Contact>> getContact() async {
    bool isGranted = await Permission.contacts.status.isGranted;
    if (!isGranted) {
      isGranted = await Permission.contacts.request().isGranted;
    }
    if (isGranted) {
      return await FastContacts.allContacts;
    }
    return [];
  }

  void selectContact(String selectContact, BuildContext conext) async{
    try {
      var userCollection =await firestore.collection('users').get();
      bool isFound = false;
      for (var document in userCollection.docs) {
        if(selectContact == document.data()['phone']){
          isFound = true;
        }
      }
      if(isFound== false){
        print('ye nahi chl rha');
        // ignore: deprecated_member_use, use_build_context_synchronously
        Scaffold.of(conext).showSnackBar(SnackBar(content: Row(
          children:const [
            Icon(Icons.no_accounts,size: 30,),
            SizedBox(width: 10,),
            Text('This Number Isn\'t Registered'),
          ],
        )));
      }
    } catch (e) {
      print(e.toString());
      throw Exception(e.toString());
    }
  }


}
