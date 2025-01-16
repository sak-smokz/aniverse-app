import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class PostWidget extends StatelessWidget {
  final String name;
  final String timestamp;
  final String content;
  final Function()? onLike;
  final Function()? onComment;
  final Function()? onShare;

  const PostWidget({
    Key? key,
    required this.name,
    required this.timestamp,
    required this.content,
    this.onLike,
    this.onComment,
    this.onShare,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16.0), // Adds space around the post card
      padding: EdgeInsets.all(12.0), // Adds space inside the post card
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Colors.white, // Card background color
        borderRadius: BorderRadius.circular(12.0), // Rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 8.0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Container(
            height: MediaQuery.of(context).size.height / 18,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.green,
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 12.0), // Space between avatar and name
                Expanded(
                  child: Text(
                    name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Text(
                  timestamp,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.0), // Space between header and content

          // Content Section
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.pink.shade50,
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: EdgeInsets.all(8.0),
            child: Text(
              content,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
          ),
          SizedBox(height: 12.0), // Space between content and actions

          // Action Buttons Section
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: onLike,
                  icon: Icon(CupertinoIcons.heart),
                  color: Colors.blue,
                ),
                IconButton(
                  onPressed: onComment,
                  icon: Icon(Icons.mode_comment_outlined),
                  color: Colors.green,
                ),
                IconButton(
                  onPressed: onShare,
                  icon: Icon(CupertinoIcons.paperplane),
                  color: Colors.purple,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
