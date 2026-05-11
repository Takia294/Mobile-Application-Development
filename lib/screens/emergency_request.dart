import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';

class EmergencyRequestScreen extends StatefulWidget {
  const EmergencyRequestScreen({super.key});

  @override
  State<EmergencyRequestScreen> createState() =>
      _EmergencyRequestScreenState();
}

class _EmergencyRequestScreenState
    extends State<EmergencyRequestScreen> {
  /// Controllers
  final TextEditingController addressController =
      TextEditingController();

  /// Request Type
  String requestType = 'Blood Donation';

  /// Selected Values
  String selectedBloodGroup = 'None';
  String selectedOrgan = 'None';
  String selectedHospital = 'None';
  String selectedUrgency = 'Medium';

  /// Blood Groups
  final List<String> bloodGroups = [
    'None',
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  /// Organ List
  final List<String> organs = [
    'None',
    'Kidney',
    'Liver',
    'Heart',
    'Lung',
    'Pancreas',
    'Cornea',
    'Bone Marrow',
    'Skin Tissue',
  ];

  /// Bangladesh Major Hospitals
  final List<String> hospitals = [
    'None',
    'Dhaka Medical College Hospital - Dhaka',
    'Square Hospital - Dhaka',
    'Evercare Hospital - Dhaka',
    'United Hospital - Dhaka',
    'Bangabandhu Sheikh Mujib Medical University - Dhaka',
    'National Institute of Kidney Diseases - Dhaka',
    'Chittagong Medical College Hospital - Chattogram',
    'Rajshahi Medical College Hospital - Rajshahi',
    'Khulna Medical College Hospital - Khulna',
    'Sylhet MAG Osmani Medical College - Sylhet',
    'Mymensingh Medical College Hospital - Mymensingh',
    'Rangpur Medical College Hospital - Rangpur',
    'Sher-E-Bangla Medical College Hospital - Barishal',
    'Cumilla Medical College Hospital - Cumilla',
  ];

  /// Urgency Levels
  final List<String> urgencyLevels = [
    'Low',
    'Medium',
    'High',
    'Critical',
  ];

  /// Submit Function
  void submitRequest() {
    if (addressController.text.trim().isEmpty) {
      _showMessage('Please enter address');
      return;
    }

    if (selectedHospital == 'None') {
      _showMessage('Please select hospital');
      return;
    }

    if (selectedBloodGroup == 'None') {
      _showMessage('Please select blood group');
      return;
    }

    if (requestType == 'Organ Donation' &&
        selectedOrgan == 'None') {
      _showMessage('Please select organ');
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.green,
        content: Text(
          'Emergency Request Submitted Successfully',
        ),
      ),
    );

    /// Reset Form
    setState(() {
      addressController.clear();
      requestType = 'Blood Donation';
      selectedBloodGroup = 'None';
      selectedOrgan = 'None';
      selectedHospital = 'None';
      selectedUrgency = 'Medium';
    });
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  void dispose() {
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EEEE),

      appBar: AppBar(
        backgroundColor: Colors.red,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Emergency Request',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(20),
          ),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  "Don't worry, We are there for you ❤️",
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 15,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              /// Request Type
              const Text(
                'Request Type',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              _dropdownContainer(
                DropdownButton<String>(
                  value: requestType,
                  isExpanded: true,
                  underline:
                      const SizedBox(),
                  items: const [
                    DropdownMenuItem(
                      value:
                          'Blood Donation',
                      child: Text(
                          'Blood Donation'),
                    ),
                    DropdownMenuItem(
                      value:
                          'Organ Donation',
                      child: Text(
                          'Organ Donation'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      requestType =
                          value!;
                    });
                  },
                ),
              ),

              const SizedBox(height: 16),

              /// Blood Group
              const Text(
                'Blood Group',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              _dropdownContainer(
                DropdownButton<String>(
                  value:
                      selectedBloodGroup,
                  isExpanded: true,
                  underline:
                      const SizedBox(),
                  items: bloodGroups
                      .map(
                        (blood) =>
                            DropdownMenuItem(
                          value: blood,
                          child:
                              Text(blood),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedBloodGroup =
                          value!;
                    });
                  },
                ),
              ),

              const SizedBox(height: 16),

              /// Organ (only for Organ Donation)
              if (requestType ==
                  'Organ Donation') ...[
                const Text(
                  'Select Organ',
                  style: TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(
                    height: 8),

                _dropdownContainer(
                  DropdownButton<
                      String>(
                    value:
                        selectedOrgan,
                    isExpanded: true,
                    underline:
                        const SizedBox(),
                    items: organs
                        .map(
                          (organ) =>
                              DropdownMenuItem(
                            value:
                                organ,
                            child:
                                Text(
                              organ,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged:
                        (value) {
                      setState(() {
                        selectedOrgan =
                            value!;
                      });
                    },
                  ),
                ),

                const SizedBox(
                    height: 16),
              ],

              /// Hospital Search
              const Text(
                'Choose Hospital',
                style: TextStyle(
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              DropdownSearch<String>(
                items: hospitals,
                selectedItem:
                    selectedHospital,
                popupProps:
                    const PopupProps
                        .menu(
                  showSearchBox:
                      true,
                  searchFieldProps:
                      TextFieldProps(
                    decoration:
                        InputDecoration(
                      hintText:
                          'Search Hospital...',
                    ),
                  ),
                ),
                dropdownDecoratorProps:
                    DropDownDecoratorProps(
                  dropdownSearchDecoration:
                      InputDecoration(
                    filled: true,
                    fillColor:
                        const Color(
                            0xFFF3EFEF),
                    border:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                                  12),
                      borderSide:
                          BorderSide
                              .none,
                    ),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    selectedHospital =
                        value ??
                            'None';
                  });
                },
              ),

              const SizedBox(height: 16),

              /// Address
              const Text(
                'Address',
                style: TextStyle(
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                controller:
                    addressController,
                decoration:
                    InputDecoration(
                  hintText:
                      'Enter Address',
                  filled: true,
                  fillColor:
                      const Color(
                          0xFFF3EFEF),
                  prefixIcon:
                      const Icon(
                    Icons.location_on,
                  ),
                  border:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius
                            .circular(
                                12),
                    borderSide:
                        BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// Urgency
              const Text(
                'Urgency Level',
                style: TextStyle(
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              _dropdownContainer(
                DropdownButton<String>(
                  value:
                      selectedUrgency,
                  isExpanded: true,
                  underline:
                      const SizedBox(),
                  items:
                      urgencyLevels
                          .map(
                            (e) =>
                                DropdownMenuItem(
                              value:
                                  e,
                              child:
                                  Text(
                                e,
                              ),
                            ),
                          )
                          .toList(),
                  onChanged:
                      (value) {
                    setState(() {
                      selectedUrgency =
                          value!;
                    });
                  },
                ),
              ),

              const SizedBox(height: 30),

              /// Submit
              SizedBox(
                width:
                    double.infinity,
                height: 55,
                child:
                    ElevatedButton(
                  style:
                      ElevatedButton
                          .styleFrom(
                    backgroundColor:
                        Colors.red,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                              14),
                    ),
                  ),
                  onPressed:
                      submitRequest,
                  child:
                      const Text(
                    'Submit Request',
                    style:
                        TextStyle(
                      fontSize: 18,
                      color: Colors
                          .white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dropdownContainer(
      Widget child) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
              horizontal: 12),
      decoration: BoxDecoration(
        color:
            const Color(0xFFF3EFEF),
        borderRadius:
            BorderRadius.circular(
                12),
      ),
      child: child,
    );
  }
}