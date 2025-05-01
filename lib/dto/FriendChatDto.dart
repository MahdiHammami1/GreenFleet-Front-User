class FriendChatDTO {
  final String userId;
  final String name;
  final String profilePictureUrl;
  final String lastMessage;
  final DateTime timestamp;

  FriendChatDTO({
    required this.userId,
    required this.name,
    required this.profilePictureUrl,
    required this.lastMessage,
    required this.timestamp,
  });

  factory FriendChatDTO.fromJson(Map<String, dynamic> json) {
    return FriendChatDTO(
      userId: json['id'].toString(),
      name: '${json['firstName']} ${json['lastName']}',
      profilePictureUrl: json['profilePicture'],
      lastMessage: json['lastMessage'],
      timestamp: DateTime.parse(json['lastMessageTime']),
    );
  }



}
