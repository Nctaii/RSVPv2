import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Wedding RSVP',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF2C3E50)),
        useMaterial3: true,
        textTheme: TextTheme(
          bodyLarge: GoogleFonts.roboto(
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      home: const RSVPPage(),
    );
  }
}

class RSVPPage extends StatefulWidget {
  const RSVPPage({super.key});

  @override
  State<RSVPPage> createState() => _RSVPPageState();
}

class _RSVPPageState extends State<RSVPPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _chickenSelected = false;
  bool _steakSelected = false;
  bool _isSubmitting = false;
  String _rsvpStatus = 'Accept'; // Default value

  String _getFoodSelection() {
    if (_rsvpStatus == 'Regret') return 'N/A';
    List<String> selections = [];
    if (_chickenSelected) selections.add('Chicken');
    if (_steakSelected) selections.add('Steak');
    return selections.isEmpty ? 'None' : selections.join(', ');
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_rsvpStatus == 'Accept' && !_chickenSelected && !_steakSelected) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Missing Selection'),
            content: const Text('Please select at least one food option'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }

      setState(() {
        _isSubmitting = true;
      });

      try {
        final response = await http.post(
          Uri.parse('https://script.google.com/macros/s/AKfycbw6oGAqAYsdhDFDldlHV6M-ubxIDq3kLhulDcG5kgiokMlFf0UZjO9fSLrEGO1goz1x/exec'),
          body: {
            'timestamp': DateTime.now().toString(),
            'name': _nameController.text,
            'status': _rsvpStatus,
            'food': _getFoodSelection(),
          },
        );

        if (response.statusCode == 200) {
          if (mounted) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('RSVP Submitted'),
                content: const Text('Thank you for your RSVP!'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          }

          // Clear the form
          _nameController.clear();
          setState(() {
            _chickenSelected = false;
            _steakSelected = false;
            _rsvpStatus = 'Accept';
          });
        } else {
          throw Exception('Failed to submit RSVP');
        }
      } catch (e) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Submission Error'),
              content: Text('Error submitting RSVP: $e'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg2.png'),
            fit: BoxFit.fill,
            colorFilter: ColorFilter.mode(
              Color(0xFF2C3E50).withOpacity(0.2),
              BlendMode.darken,
            ),
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'RSVP',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 60,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'by August 1st, twenty twenty five',
                    style: GoogleFonts.pinyonScript(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: (MediaQuery.sizeOf(context).width)/9),
                    child: TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your full name';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Will you attend?',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio<String>(
                        value: 'Accept',
                        groupValue: _rsvpStatus,
                        onChanged: _isSubmitting ? null : (String? value) {
                          setState(() {
                            _rsvpStatus = value!;
                          });
                        },
                      ),
                      const Text('Accept'),
                      const SizedBox(width: 32),
                      Radio<String>(
                        value: 'Regret',
                        groupValue: _rsvpStatus,
                        onChanged: _isSubmitting ? null : (String? value) {
                          setState(() {
                            _rsvpStatus = value!;
                            if (value == 'Regret') {
                              _chickenSelected = false;
                              _steakSelected = false;
                            }
                          });
                        },
                      ),
                      const Text('Regret'),
                    ],
                  ),
                  if (_rsvpStatus == 'Accept') ...[
                    const SizedBox(height: 24),
                    const Text(
                      'Please select your meal preference(s):',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Checkbox(
                            value: _chickenSelected,
                            onChanged: _isSubmitting ? null : (bool? value) {
                              setState(() {
                                _chickenSelected = value ?? false;
                                if (_chickenSelected) _steakSelected = false;
                              });
                            },
                          ),
                          const Text('Chicken'),
                          const SizedBox(width: 24),
                          Checkbox(
                            value: _steakSelected,
                            onChanged: _isSubmitting ? null : (bool? value) {
                              setState(() {
                                _steakSelected = value ?? false;
                                if (_steakSelected) _chickenSelected = false;
                              });
                            },
                          ),
                          const Text('Beef'),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2C3E50),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Submit RSVP', style: TextStyle(color: Color(0xffE0E0E0)),),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}