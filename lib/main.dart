import 'package:flutter/material.dart';

void main() {
  runApp(PocketFlowApp());
}

class PocketFlowApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PocketFlow',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: MainScreen(),
    );
  }
}

class Transaction {
  String id;
  String title;
  double amount;
  bool isIncome;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.isIncome,
  });
}

class MainScreen extends StatefulWidget {
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _index = 0;

  List<Transaction> transactions = [];

  void addTransaction(String title, double amount, bool isIncome) {
    setState(() {
      transactions.add(Transaction(
        id: DateTime.now().toString(),
        title: title,
        amount: amount,
        isIncome: isIncome,
      ));
    });
  }

  void deleteTransaction(String id) {
    setState(() {
      transactions.removeWhere((tx) => tx.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> screens = [
      HomeScreen(transactions),
      TransactionsScreen(transactions, addTransaction, deleteTransaction),
      GoalsScreen(transactions),
      InsightsScreen(transactions),
    ];

    return Scaffold(
      body: screens[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "Transactions"),
          BottomNavigationBarItem(icon: Icon(Icons.flag), label: "Goals"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Insights"),
        ],
      ),
    );
  }
}

// ---------------- HOME SCREEN ----------------

class HomeScreen extends StatelessWidget {
  final List<Transaction> transactions;

  HomeScreen(this.transactions);

  double get income => transactions
      .where((t) => t.isIncome)
      .fold(0, (sum, t) => sum + t.amount);

  double get expense => transactions
      .where((t) => !t.isIncome)
      .fold(0, (sum, t) => sum + t.amount);

  @override
  Widget build(BuildContext context) {
    double balance = income - expense;
    double goal = 10000;
    double progress = (balance / goal).clamp(0, 1);

    return Scaffold(
      appBar: AppBar(title: Text("Dashboard")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Card(child: ListTile(title: Text("Balance"), subtitle: Text("₹$balance"))),
            Card(child: ListTile(title: Text("Income"), subtitle: Text("₹$income"))),
            Card(child: ListTile(title: Text("Expense"), subtitle: Text("₹$expense"))),
            SizedBox(height: 20),
            Text("Savings Goal Progress"),
            LinearProgressIndicator(value: progress),
          ],
        ),
      ),
    );
  }
}

// ---------------- TRANSACTIONS SCREEN ----------------

class TransactionsScreen extends StatelessWidget {
  final List<Transaction> transactions;
  final Function addTx;
  final Function deleteTx;

  TransactionsScreen(this.transactions, this.addTx, this.deleteTx);

  final TextEditingController titleCtrl = TextEditingController();
  final TextEditingController amountCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Transactions")),
      body: transactions.isEmpty
          ? Center(child: Text("No transactions yet"))
          : ListView(
              children: transactions.map((tx) => ListTile(
                title: Text(tx.title),
                subtitle: Text("₹${tx.amount}"),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => deleteTx(tx.id),
                ),
              )).toList(),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) {
              bool isIncome = false;
              return AlertDialog(
                title: Text("Add Transaction"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleCtrl,
                      decoration: InputDecoration(labelText: "Title"),
                    ),
                    TextField(
                      controller: amountCtrl,
                      decoration: InputDecoration(labelText: "Amount"),
                      keyboardType: TextInputType.number,
                    ),
                    SwitchListTile(
                      title: Text("Income"),
                      value: isIncome,
                      onChanged: (val) {},
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      addTx(
                        titleCtrl.text,
                        double.parse(amountCtrl.text),
                        false,
                      );
                      Navigator.pop(context);
                    },
                    child: Text("Add"),
                  )
                ],
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

// ---------------- GOALS SCREEN ----------------

class GoalsScreen extends StatelessWidget {
  final List<Transaction> transactions;

  GoalsScreen(this.transactions);

  @override
  Widget build(BuildContext context) {
    double goal = 10000;
    double saved = transactions
        .where((t) => t.isIncome)
        .fold(0, (sum, t) => sum + t.amount);

    double progress = (saved / goal).clamp(0, 1);

    return Scaffold(
      appBar: AppBar(title: Text("Savings Goal")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text("Goal: ₹$goal"),
            SizedBox(height: 10),
            LinearProgressIndicator(value: progress),
            SizedBox(height: 10),
            Text("Saved: ₹$saved"),
          ],
        ),
      ),
    );
  }
}

// ---------------- INSIGHTS SCREEN ----------------

class InsightsScreen extends StatelessWidget {
  final List<Transaction> transactions;

  InsightsScreen(this.transactions);

  @override
  Widget build(BuildContext context) {
    double totalExpense = transactions
        .where((t) => !t.isIncome)
        .fold(0, (sum, t) => sum + t.amount);

    return Scaffold(
      appBar: AppBar(title: Text("Insights")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text("Total Expenses: ₹$totalExpense"),
            SizedBox(height: 10),
            Text("Tip: Try reducing daily spending 👀"),
          ],
        ),
      ),
    );
  }
}