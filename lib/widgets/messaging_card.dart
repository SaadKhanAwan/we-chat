import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatting_app_practice/api/apis.dart';
import 'package:chatting_app_practice/helper/diloguebox.dart';
import 'package:chatting_app_practice/helper/mydate.dart';
import 'package:chatting_app_practice/main.dart';
import 'package:chatting_app_practice/models/message.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MessagingCard extends StatefulWidget {
  final Message message;
  const MessagingCard({super.key, required this.message});

  @override
  State<MessagingCard> createState() => _MessagingCardState();
}

class _MessagingCardState extends State<MessagingCard> {
  @override
  Widget build(BuildContext context) {
    bool isme = APIs.user.uid == widget.message.fromId;
    return InkWell(
        onLongPress: () {
          _showbuttomsheet(isme);
        },
        child: isme ? greenmessage() : bluemessage());
  }

  // sender message or blue message
  Widget bluemessage() {
    // updating last read message if userreciver are different
    if (widget.message.read.isNotEmpty) {
      APIs.updateMessageingReadStatus(widget.message);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            decoration: BoxDecoration(
                color: const Color.fromARGB(255, 241, 245, 255),
                border: Border.all(color: Colors.blue),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                )),
            padding: EdgeInsets.all(widget.message.type == Type.image
                ? mq.width * .03
                : mq.width * .04),
            margin: EdgeInsets.symmetric(
                horizontal: mq.width * .04, vertical: mq.height * .01),
            child: widget.message.type == Type.text
                ? Text(
                    widget.message.msg,
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * .01),
                    child: CachedNetworkImage(
                      fit: BoxFit.contain,
                      imageUrl: widget.message.msg,
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.person,
                        size: 70,
                      ),
                    ),
                  ),
          ),
        ),
        // this is for sender send time
        Padding(
          padding: EdgeInsets.only(right: mq.width * .04),
          child: Text(
            Mydate.getFormatedtime(context: context, time: widget.message.sent),
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ),
      ],
    );
  }

  // our message or green message
  Widget greenmessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // for adding some space
        Row(
          children: [
            SizedBox(
              width: mq.width * .04,
            ),
            // for double tick
            if (widget.message.read.isNotEmpty)
              // this is double tick icon
              const Icon(
                Icons.done_all_rounded,
                color: Colors.blue,
              ),
            // for adding some space
            SizedBox(
              width: mq.width * .04,
            ),
            // for read time when message is read
            Text(
              Mydate.getFormatedtime(
                  context: context, time: widget.message.sent),
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
        Flexible(
          child: Container(
            decoration: BoxDecoration(
                color: const Color.fromARGB(255, 218, 255, 176),
                border: Border.all(color: Colors.lightGreen),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                  bottomLeft: Radius.circular(30),
                )),
            padding: EdgeInsets.all(widget.message.type == Type.image
                ? mq.width * .03
                : mq.width * .04),
            margin: EdgeInsets.symmetric(
                horizontal: mq.width * .04, vertical: mq.height * .01),
            child: widget.message.type == Type.text
                ? Text(
                    widget.message.msg,
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * .01),
                    child: CachedNetworkImage(
                      fit: BoxFit.contain,
                      imageUrl: widget.message.msg,
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.person,
                        size: 70,
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  // for buttomsheet for modefing message details
  void _showbuttomsheet(bool isme) {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            children: [
              // black divider
              Container(
                height: 4,
                margin: EdgeInsets.symmetric(
                    vertical: mq.height * 0.015, horizontal: mq.width * 0.4),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8), color: Colors.grey),
              ),
              widget.message.type == Type.text
                  ? // copy option
                  OptionItem(
                      name: "Copy",
                      icon: const Icon(
                        Icons.copy_all_rounded,
                        size: 26,
                        color: Colors.blue,
                      ),
                      callback: () async {
                        await Clipboard.setData(
                                ClipboardData(text: widget.message.msg))
                            .then((value) {
                          // for hiding bottom sheet
                          Navigator.pop(context);
                          Dilogue.showsnabar(context, "Text Copied");
                        });
                      })
                  : // copy option
                  OptionItem(
                      name: "Save Image",
                      icon: const Icon(
                        Icons.download,
                        size: 26,
                        color: Colors.blue,
                      ),
                      callback: () async {}),
              Divider(
                color: Colors.black54,
                endIndent: mq.width * .04,
                indent: mq.height * .04,
              ),
              // Edit option
              if (widget.message.type == Type.text && isme)
                OptionItem(
                    name: "Edit",
                    icon: const Icon(
                      Icons.edit,
                      size: 26,
                      color: Colors.blue,
                    ),
                    callback: () {
                      // for hiding bottom sheet
                      Navigator.pop(context);
                      _showMessageUpdateDilogue();
                    }),
              // delete option
              OptionItem(
                  name: "Delete",
                  icon: const Icon(
                    Icons.delete,
                    size: 26,
                    color: Colors.red,
                  ),
                  callback: () async {
                    await APIs.deletemessage(widget.message).then((value) {
                      // for hiding navigaton dar
                      Navigator.pop(context);
                    });
                  }),
              Divider(
                color: Colors.black54,
                endIndent: mq.width * .04,
                indent: mq.height * .04,
              ),

              // Sent time option
              OptionItem(
                  name:
                      "Sent at ${Mydate.getformatedmessagetime(context: context, time: widget.message.sent)} ",
                  icon: const Icon(
                    Icons.remove_red_eye,
                    size: 26,
                    color: Colors.blue,
                  ),
                  callback: () {}),
              // copy option
              OptionItem(
                  name: widget.message.read.isEmpty
                      ? "Not Read Yet"
                      : "Read at ${Mydate.getformatedmessagetime(context: context, time: widget.message.read)}  ",
                  icon: const Icon(
                    Icons.remove_red_eye,
                    size: 26,
                    color: Colors.green,
                  ),
                  callback: () {}),
            ],
          );
        });
  }

  void _showMessageUpdateDilogue() {
    String updatemsg = widget.message.msg;

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              contentPadding: const EdgeInsets.only(
                  left: 24, right: 24, top: 20, bottom: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: const Row(
                children: [
                  Icon(
                    Icons.message,
                    color: Colors.blue,
                    size: 28,
                  ),
                  Text("Update Message")
                ],
              ),
              content: TextFormField(
                maxLines: null,
                onChanged: (value) => updatemsg = value,
                initialValue: updatemsg,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15))),
              ),
              actions: [
                // for cancel button
                MaterialButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Cancel",
                        style: TextStyle(color: Colors.blue, fontSize: 16))),
                // for update button
                MaterialButton(
                    onPressed: () {
                      APIs.updatemessage(widget.message, updatemsg);
                      Navigator.pop(context);
                      Dilogue.showsnabar(
                          context, "Message updated succussfully");
                    },
                    child: const Text("Update",
                        style: TextStyle(color: Colors.blue, fontSize: 16)))
              ],
            ));
  }
}

// this is for reused widgrt
class OptionItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final VoidCallback callback;
  const OptionItem(
      {super.key,
      required this.name,
      required this.icon,
      required this.callback});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => callback(),
      child: Padding(
        padding: EdgeInsets.only(
            left: mq.width * .05,
            top: mq.height * .015,
            bottom: mq.height * .025),
        child: Row(children: [
          icon,
          Flexible(
              child: Text(
            name,
            style: const TextStyle(
                letterSpacing: 0.5, fontSize: 15, color: Colors.black54),
          )),
        ]),
      ),
    );
  }
}
