import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notes_app/services/cloud/cloud_storage_constants.dart';

@immutable
class CloudNote {
  final String documentId;
  final String ownerUserId;
  final String text;
  final String title;
  final Timestamp createdAt;
  final Timestamp updatedAt;
  const CloudNote({
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    required this.documentId,
    required this.ownerUserId,
    required this.text,
  });

  CloudNote.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
    : title = snapshot.data()[titleField] as String,
      createdAt = snapshot.data()[createdAtField],
      updatedAt = snapshot.data()[updatedAtField],
      documentId = snapshot.id,
      ownerUserId = snapshot.data()[ownerUserIdFieldName],
      text = snapshot.data()[contentField] as String;
}
