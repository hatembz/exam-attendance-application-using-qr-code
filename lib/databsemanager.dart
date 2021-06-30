import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:memoire/screens/studentlist.dart';

class DatabaseManager {

  Future  founduserdetails(@required id) async {
    List foundDetails = [];
  try{
      await FirebaseFirestore.instance
          .collection('users')
          .where("nom", isEqualTo: id)
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((element) {
          foundDetails.add(element.data());
          foundDetails.add(element.id);
        });
      });
  return foundDetails;
  }catch(e){
    print(e);
  }
  }

  Future getuserList() async {
    List itemList = [];
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .where(FieldPath.documentId,
          isEqualTo: FirebaseAuth.instance.currentUser.uid)
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((element) {
          itemList.add(element.data());
        }
        );
      });
      return itemList;
    } catch (e) {
      print("error:${e.toString()}");
      return null;
    }
  }

  Future getStudentInfo(@required id) async {
    List userProfile = [];
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .where(FieldPath.documentId,
          isEqualTo: id)
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((element) {
          userProfile.add(element.data());
        }
        );
      });
      return userProfile;
    } catch (e) {
      print("error:${e.toString()}");
      return null;
    }
  }

  Future getExamListe() async {
   List itemList=[];
    try {
      await FirebaseFirestore.instance
          .collection("exam")
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((element) {
        itemList.add(element.data());
        });
        print(itemList);
      }
      );
      return itemList;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  List selected = [];

  Future selectedItem(@required id) async {
    try {
      await FirebaseFirestore.instance
          .collection('exam').where(FieldPath.documentId, isEqualTo: id)
          .get()
          .then((value) =>
          value.docs.forEach((element) {
            selected.add(element.data());
          }));
      return selected;
    } catch (e) {
      print(e);
    }
    print('selected item:$selected');
  }

  List selecteditem = [];

  Future selecteditemdetails(@required id, @required type) async {
    try {
      await FirebaseFirestore.instance
          .collection('exam').doc(id).collection('planing')
          .where(
          type, arrayContainsAny: [FirebaseAuth.instance.currentUser.uid])
          .get()
          .then((value) {
        if (type == 'etudiant') {
          value.docs.forEach((element) {
            selecteditem.add(element.data()['salle']);
            selecteditem.add(element.id);
          }
          );
        } else {
          value.docs.forEach((element) {
            selecteditem.add(element.data());
          });
        }
      }
      );
      return selecteditem;
    } catch (e) {
      print("default is :$e");
    }
  }

  Future selectedstudent(@required id) async {
    try {
      await FirebaseFirestore.instance.collection('users').where(
          FieldPath.documentId, isEqualTo: id).get().then((
          value) =>
          value.docs.forEach((element) {
            selecteditem.add(element.data());
               })
            );
      return selecteditem;
    } catch (e) {
      print("default is :$e");
    }}

  List studentlist = [];

  Future getStudentList() async {
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .where("category",
          isEqualTo: 'student')
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((element) {
          studentlist.add(element.data());
        }
        );
      });
      print("student list:$studentlist");
      return studentlist;
    } catch (e) {
      print("error:${e.toString()}");
      return null;
    }
  }
}