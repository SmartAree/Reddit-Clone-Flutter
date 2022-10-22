import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:reddit_clone/Core/Constants/constants.dart';
import 'package:reddit_clone/Core/Constants/firebase_constants.dart';
import 'package:reddit_clone/Core/Providers/firebase_providers.dart';
import 'package:reddit_clone/Models/user_model.dart';

final authRepoProvider = Provider(
  (ref) => AuthRepository(
    //!ref.read usually used outside of the buildContext when you don't want to listen any of the changes made in the provider
    auth: ref.read(authProvider), //? gives us the instance of authProvider
    firestore: ref.read(firebaseProvider),
    googleSignIn: ref.read(googleSigninProvider),
  ),
);

class AuthRepository {
  //!!!Private variables
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final GoogleSignIn
      _googleSignIn; //? provides methods to view the email of our google accounts

//****we cannot access private variables in the constructor so we can assign private to public***\\
  AuthRepository(
      //!public variables
      {required FirebaseAuth auth,
      required FirebaseFirestore firestore,
      required GoogleSignIn googleSignIn})
      : //*Private assigned to public
        _auth = auth,
        _firestore = firestore,
        _googleSignIn = googleSignIn;

  CollectionReference get _user =>
      _firestore.collection(FirebaseConstants.usersCollection);

//**************Signin Google****************//

  void signinWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final googleAuth = await googleUser?.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      //? User credential
      //**************Register User****************//
      UserCredential userCredential =
          await _auth.signInWithCredential(credential);

//**************UserModel Instance****************//

      UserModel userModel = UserModel(
        banner: Constants.bannerDefault,
        username: userCredential.user!.displayName ?? 'Untitled',
        karma: 0,
        profilePic: userCredential.user!.photoURL ?? Constants.avatarDefault,
        uid: userCredential.user!.uid,
        awards: [],
        isAuthenticated: true,
      );
//**************Save user credentials to database****************//
      await _user.doc(userCredential.user!.uid).set(userModel.toMap());
    } catch (e) {
      print(e);
    }
  }
}
