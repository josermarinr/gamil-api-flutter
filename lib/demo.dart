import 'dart:async';

import 'package:casademo/save_temp_file.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/gmail/v1.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as auth show AuthClient;

import './open_modal_pdf.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn(
    // Optional clientId
    // clientId: '[YOUR_OAUTH_2_CLIENT_ID]',
    scopes: <String>[
      // GmailApi.mailGoogleComScope, //'https://mail.google.com/'
      // GmailApi.gmailModifyScope, // 'https://www.googleapis.com/auth/gmail.modify'
      GmailApi
          .gmailReadonlyScope, // 'https://www.googleapis.com/auth/gmail.readonly'
    ]);

/// The main widget of this demo.
class SignInDemo extends StatefulWidget {
  /// Creates the main widget of this demo.
  const SignInDemo({super.key});
  @override
  State createState() => SignInDemoState();
}

/// The state of the main widget.
class SignInDemoState extends State<SignInDemo> {
  GoogleSignInAccount? _currentUser;
  String _contactText = '';
  late GmailApi gmailApi;
  final _formKey = GlobalKey<FormState>();
  final myController = TextEditingController();
  List messageList = [];

  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      setState(() {
        _currentUser = account;
      });
    });
    _googleSignIn.signInSilently();
  }

  Future<void> _handleGetContact(String userPrompt) async {
    setState(() {
      _contactText = 'Loading contact info...';
    });

    // Retrieve an [auth.AuthClient] from the current [GoogleSignIn] instance.
    final auth.AuthClient? client = await _googleSignIn.authenticatedClient();

    assert(client != null, 'Authenticated client missing!');

    // Prepare a People Service authenticated client.
    final GmailApi gmailApi = GmailApi(client!);

    // List of message
    final ListMessagesResponse message = await gmailApi.users.messages.list(
      'me',
      maxResults: 10,
      q: '(has:pdf (commande OR achat OR livraison OR facture) AND $userPrompt) has:attachment',
      includeSpamTrash: false,
    );

    final messages = message.messages;
    if (messages != null) {
      //get messages
      for (var element in messages) {
        Message messageContent =
            await gmailApi.users.messages.get('me', element.id!);
        String attachementId =
            messageContent.payload!.parts![1].body!.attachmentId!;
        MessagePartBody attachment = await gmailApi.users.messages.attachments
            .get('me', element.id!, attachementId);

        String messageType = messageContent.payload!.parts![1].mimeType!;

        if (messageType == 'application/pdf' && attachment.data != null) {
          // save to file

          String path = await saveToTempDirectory(
              attachment.data!, messageContent.payload!.parts![1].filename!);
          setState(() {
            messageList.add({
              "message": messageContent.payload!.parts![0].body!.data,
              "attachments": attachment.data,
              "attachmentsName": messageContent.payload!.parts![1].filename,
              "attachmentType": messageContent.payload!.parts![1].mimeType,
              "path": path,
              "pdfData": decodeBase64Url(attachment.data!),
            });
          });
        }
      }
    }
    // get attachments

    // get attachment content decrypt and save to file
    setState(() {
      if (messageList.isNotEmpty) {
        _contactText = 'I see your message ${messageList.length}';
      } else {
        _contactText = 'No messages to display.';
      }
    });
  }

  Future<void> _handleSignIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      print(error); // ignore: avoid_print
    }
  }


  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }


  Future<void> _handleSignOut() => _googleSignIn.disconnect();

  Widget _buildBody() {
    final GoogleSignInAccount? user = _currentUser;
    if (user != null) {
      return SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Card(
              child: ListTile(
                leading: GoogleUserCircleAvatar(
                  identity: user,
                ),
                title: Text(user.displayName ?? ''),
                subtitle: Text(user.email),
              ),
            ),
            SizedBox(
              height: 400,
              child: ListView.builder(
                itemCount: messageList.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      leading: InkWell(
                        onTap: () => OpenModalPdf(
                                path: messageList[index]["path"],
                                context: context)
                            .showModal(),
                        child: const Icon(Icons.attach_file),
                      ),
                      title: Text(messageList[index]["attachmentsName"]),
                    ),
                  );
                },
              ),
            ),
            Text(_contactText),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                ElevatedButton(
                  onPressed: _handleSignOut,
                  child: const Text('SIGN OUT'),
                ),
              ],
            )
          ],
        ),
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          const Text('You are not currently signed in.'),
          ElevatedButton(
            onPressed: _handleSignIn,
            child: const Text('SIGN IN'),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Search email with Gmail API'),
        ),
        body: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Form(
                  key: _formKey,
                  child: Container(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: myController,
                              // The validator receives the text that the user has entered.
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter some text';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(
                            width: 10),
                          Expanded(
                            flex: 1,
                            child: ElevatedButton(
                              onPressed: () {
                                // Validate returns true if the form is valid, or false otherwise.
                                if (_formKey.currentState!.validate()) {
                                  // If the form is valid, display a snackbar. In the real world,
                                  // you'd often call a server or save the information in a database.
                                  _handleGetContact(myController.text);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                     SnackBar(content: Text('Searching email with the keyword ${myController.text}')),
                                  );
                                }
                              },
                              child: const Text('Submit'),
                            ),
                          ),
                        ]
                    ),
                  )),
              Expanded(
                child: ConstrainedBox(
                  constraints: const BoxConstraints.expand(),
                  child: _buildBody(),
                ),
              ),
            ],
          ),
        ));
  }
}
