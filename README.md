# ZIMKit(ZegoCloud In-App Chat UIKit)

## 1. init imkit

```
void main() {
  ZIMKit().init(
    appID: , // your appid
    appSign: '', // your appSign
  );
  runApp(const ZIMKitDemo());
}
```

## 2. user login

```dart
ElevatedButton(
    onPressed: () async {
        await ZIMKit()
            .connectUser(id: userID.text, name: userName.text);
            Navigator.of(context).pushReplacement(
            MaterialPageRoute(
                builder: (context) =>
                    const ZIMKitDemoHomePage(),
            ),
        );
    },
    child: const Text("login"),
)
```

## 3. enjoy it

```dart
class ZIMKitDemoHomePage extends StatelessWidget {
  const ZIMKitDemoHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Conversations'),
          actions: const [HomePagePopupMenuButton()],
        ),
        body: ZIMKitConversationListView(
          onPressed: (context, conversation, defaultAction) {
            Navigator.push(context, MaterialPageRoute(
              builder: (context) {
                return ZIMKitMessageListPage(
                  conversationID: conversation.id,
                  conversationType: conversation.type,
                );
              },
            ));
          },
        ),
      ),
    );
  }
}

```
