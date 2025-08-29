import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:to_do_app/services/cloud/cloud_storage_constants.dart';

@immutable
class CloudNote {
  final String documentId;
  final String ownerUserId;
  final String text;
  final String title;
  final Timestamp timestamp;
  const CloudNote({
    required this.title,
    required this.timestamp,
    required this.documentId,
    required this.ownerUserId,
    required this.text,
  });

  CloudNote.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
    : title = snapshot.data()[titleField] as String,
      timestamp = snapshot.data()[timestampField],
      documentId = snapshot.id,
      ownerUserId = snapshot.data()[ownerUserIdFieldName],
      text = snapshot.data()[textField] as String;
}
