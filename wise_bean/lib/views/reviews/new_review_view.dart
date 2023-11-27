import 'package:flutter/material.dart';
import 'package:wise_bean/services/auth/auth_service.dart';
import 'package:wise_bean/services/crud/review_service.dart';

class NewReviewView extends StatefulWidget {
  const NewReviewView({super.key});

  @override
  State<NewReviewView> createState() => _NewReviewViewState();
}

class _NewReviewViewState extends State<NewReviewView> {
  DatabaseReview? _review;
  late final ReviewsService _reviewsService;
  late final TextEditingController _remarksTextController;
  double _descriptionCorrectness = 3.0;
  double _balance = 3.0;
  double _enjoymnet = 3.0;
  double _totalRate = 3.0;
  final List<double> _sliderValuesRange = [1, 2, 3, 4, 4.5, 4.6, 4.8, 5];
  final Map<double, double> _matchMap = {
    0: 1.0,
    1: 2.0,
    2: 3.0,
    3: 4.0,
    4: 4.5,
    5: 4.6,
    6: 4.8,
    7: 5.0,
  };

  Future<DatabaseReview> createNewReview() async {
    final existingReview = _review;
    if (existingReview != null) {
      return existingReview;
    }
    final currentUser = AuthService.firebase().currentUser!;
    final email = currentUser.email!;
    final owner = await _reviewsService.getUser(email: email);
    return await _reviewsService.createReview(balance: _balance,descriptionCorrectness: _descriptionCorrectness, totalRate: _totalRate, enjoyment: _enjoymnet, remarks: _remarksTextController.text, owner: owner);
  }

  @override
  void initState() {
    _reviewsService = ReviewsService();
    _remarksTextController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _remarksTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New review'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            const Text('Rate the balance'),
            Slider(
              value: _balance,
              onChanged: (newBalance) {
                setState(() {
                  _balance = newBalance;
                  recalculateTotalRate();
                });
              },
              divisions: 7,
              label: _sliderValuesRange[_balance.round()].toString(),
              min: 0,
              max: 7,
            ),
            const Text('Rate the correcteness of description'),
            Slider(
              value: _descriptionCorrectness,
              onChanged: (newDescriptionCorrectness) {
                setState(() {
                  _descriptionCorrectness = newDescriptionCorrectness;
                  recalculateTotalRate();
                });
              },
              divisions: 7,
              label: _sliderValuesRange[_descriptionCorrectness.round()]
                  .toString(),
              min: 0,
              max: 7,
            ),
            const Text('Rate your enjoyment'),
            Slider(
              value: _enjoymnet,
              onChanged: (newEnjoyment) {
                setState(() {
                  _enjoymnet = newEnjoyment;
                  recalculateTotalRate();
                });
              },
              divisions: 7,
              label: _sliderValuesRange[_enjoymnet.round()].toString(),
              min: 0,
              max: 7,
            ),
            Text(
              "Total rating is $_totalRate",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 30,
            ),
            TextField(
              controller: _remarksTextController,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              decoration:
                  const InputDecoration(hintText: 'Type your remarks here...'),
            ),
            const SizedBox(
              height: 30,
            ),
            ElevatedButton(
                onPressed: () async {
                  await createNewReview();
                },
                child: const Text('Save review'))
          ],
        ),
      ),
    );
  }

  double convertToRealValue(double fakeValue) {
    return _matchMap[fakeValue] ?? 3.0;
  }

  void recalculateTotalRate() {
    double notRoundedRate = (convertToRealValue(_descriptionCorrectness) +
            convertToRealValue(_balance) +
            convertToRealValue(_enjoymnet)) /
        3;
    _totalRate = double.parse(notRoundedRate.toStringAsFixed(1));
  }
}
