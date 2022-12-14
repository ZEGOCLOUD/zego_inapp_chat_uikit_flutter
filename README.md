
# ZegoIMKit(ZegoCloud In-App Chat UIKit)
## 1. init imkit

```
void main() {
  ZegoIMKit().init(
    appID: , // your appid
    appSign: '', // your appSign
  );
  runApp(const ZegoIMKitDemo());
}
```


## 2. user login

```dart
ElevatedButton(
    onPressed: () async {
        await ZegoIMKit()
            .login(id: userID.text, name: userName.text);
            Navigator.of(context).pushReplacement(
            MaterialPageRoute(
                builder: (context) =>
                    const ZegoIMKitDemoHomePage(),
            ),
        );
    },
    child: const Text("login"),
)
```

## 3. enjoy it

```dart
class ZegoIMKitDemoHomePage extends StatelessWidget {
  const ZegoIMKitDemoHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Conversations'),
          actions: const [HomePagePopupMenuButton()],
        ),
        body: ZegoConversationListView(
          onPressed: (context, conversation, defaultAction) {
            Navigator.push(context, MaterialPageRoute(
              builder: (context) {
                return ZegoMessageListPage(
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