import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reddit_clone/Core/Constants/firebase_constants.dart';
import 'package:reddit_clone/Core/Providers/firebase_providers.dart';
import 'package:reddit_clone/Core/failure.dart';
import 'package:reddit_clone/Core/type_def.dart';
import 'package:reddit_clone/Models/community_model.dart';

//*****getting firestore instance from firebase provider******//
final communityRepoProvider = Provider(
  (ref) => CommunityRepository(
    firestore: ref.read(firebaseProvider),
  ),
);

class CommunityRepository {
  final FirebaseFirestore _firestore;

  CommunityRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

//*********************Create Community Fucntion *********//

  FutureVoid createCommunity(CommunityModel communityModel) async {
    try {
      //?getting the data what user named the community
      var communityDoc = await _communities.doc(communityModel.name).get();
      //? checking if it exists then throw an exception
      if (communityDoc.exists) {
        throw 'Community with the same name already exists!';
      }
      //? checking if does not exists then set the new community name and save it to the firebase

      return right(
          _communities.doc(communityModel.name).set(communityModel.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(
        Failure(
          e.toString(),
        ),
      );
    }
  }

//******to display the create communities in the drawer in which the user have joined **********//
  Stream<List<CommunityModel>> getUserCommunity(String uid) {
//? we went to the community collections to find members containing user id then we've got the snapshot which will return the querysnapshot we've map through the querysnapshot then we've ran a for loop so that we get through every querysnapshot

//? because querysnapshot contains the list of documents snapshots, then we are adding documents in the list of communities

//! snapshot => list of querysnapshots
//!map((event)) => one single querysnapshot
    return _communities
        .where('members', arrayContains: uid)
        .snapshots()
        .map((event) {
      List<CommunityModel> communities = [];
      for (var doc in event.docs) {
        communities.add(
          CommunityModel.fromMap(doc.data() as Map<String, dynamic>),
        );
      }
      return communities;
    });
  }

//*******To get community by name  ********//
  Stream<CommunityModel> getCommunityByName(String name) {
    return _communities.doc(name).snapshots().map((event) =>
        CommunityModel.fromMap(event.data() as Map<String, dynamic>));
  }

  //**** Edit Community data saving****/

  FutureVoid editCommunity(CommunityModel communityModel) async {
    try {
      return right(
        _communities.doc(communityModel.name).update(
              communityModel.toMap(),
            ),
      );
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(
        Failure(
          e.toString(),
        ),
      );
    }
  }

  CollectionReference get _communities =>
      _firestore.collection(FirebaseConstants.communitiesCollection);
}
