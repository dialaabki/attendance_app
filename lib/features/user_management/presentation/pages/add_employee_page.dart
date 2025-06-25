import 'package:attendance_app/core/common_widgets/admin_page_shell.dart';
import 'package:attendance_app/features/auth/business/entities/user_entity.dart';
import 'package:attendance_app/features/user_management/business/usecases/add_employee.dart';
import 'package:attendance_app/service_locator.dart';
import 'package:flutter/material.dart';

class AddEmployeePage extends StatefulWidget {
  const AddEmployeePage({super.key});
  @override
  _AddEmployeePageState createState() => _AddEmployeePageState();
}

class _AddEmployeePageState extends State<AddEmployeePage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _locationNameController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _salaryController = TextEditingController();
  bool _isLoading = false;

  String _selectedRole = 'Employee';
  String _selectedType = 'Full-Time';
  TimeOfDay _standardStartTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _standardEndTime = const TimeOfDay(hour: 18, minute: 0);
  final Set<String> _selectedDays = {'Sun', 'Mon', 'Tue', 'Wed', 'Thu'};
  final List<CustomScheduleEntity> _customSchedules = [];

  // --- FIX IS HERE ---
  // Add 'HR' to the list of roles that the admin can select.
  final List<String> _roles = ['Employee', 'Admin', 'HR'];
  final List<String> _types = ['Full-Time', 'Part-Time', 'Contractor', 'Intern'];
  final List<String> _daysOfWeek = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _locationNameController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  Future<void> _saveUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final addEmployeeUseCase = sl<AddEmployee>();

    final params = AddEmployeeParams(
      fullName: _fullNameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      role: _selectedRole,
      type: _selectedType,
      standardWorkDays: _selectedDays,
      standardStartTime: _standardStartTime,
      standardEndTime: _standardEndTime,
      locationName: _locationNameController.text.trim(),
      latitude: double.tryParse(_latitudeController.text.trim()) ?? 0.0,
      longitude: double.tryParse(_longitudeController.text.trim()) ?? 0.0,
      customSchedules: _customSchedules,
      salary: double.tryParse(_salaryController.text.trim()) ?? 0.0,
    );

    final result = await addEmployeeUseCase(params);

    if (mounted) {
      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message), backgroundColor: Colors.red));
        },
        (_) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User added successfully!'), backgroundColor: Colors.green));
          Navigator.of(context).pop();
        },
      );
      setState(() => _isLoading = false);
    }
  }

  void _addCustomSchedule() {
    final usedDays = _customSchedules.map((s) => s.day).toSet();
    String? firstAvailableDay;
    for (var day in _daysOfWeek) {
      if (!usedDays.contains(day)) {
        firstAvailableDay = day;
        break;
      }
    }
    if (firstAvailableDay != null) {
      setState(() => _customSchedules.add(CustomScheduleEntity(
            day: firstAvailableDay!,
            startTime: const TimeOfDay(hour: 9, minute: 0),
            endTime: const TimeOfDay(hour: 15, minute: 0),
          )));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All days have a custom schedule.')));
    }
  }

  Future<void> _selectTime(BuildContext context, {required bool isStartTime, int? scheduleIndex}) async {
    final initialTime = scheduleIndex != null 
      ? (isStartTime ? _customSchedules[scheduleIndex].startTime : _customSchedules[scheduleIndex].endTime)
      : (isStartTime ? _standardStartTime : _standardEndTime);

    final TimeOfDay? picked = await showTimePicker(context: context, initialTime: initialTime);
    if (picked != null) {
      setState(() {
        if (scheduleIndex != null) {
          final oldSchedule = _customSchedules[scheduleIndex];
          _customSchedules[scheduleIndex] = CustomScheduleEntity(
            day: oldSchedule.day, 
            startTime: isStartTime ? picked : oldSchedule.startTime, 
            endTime: isStartTime ? oldSchedule.endTime : picked
          );
        } else {
          if (isStartTime) {
            _standardStartTime = picked;
          } else {
            _standardEndTime = picked;
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFDAC844);

    return AdminPageShell(
      title: 'Add User',
      showBackButton: true,
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(25.0),
          children: [
            _buildSectionTitle('Account Details'),
            _buildTextField(label: 'Full Name', controller: _fullNameController),
            _buildTextField(label: 'Email (for login)', controller: _emailController, keyboardType: TextInputType.emailAddress),
            _buildTextField(label: 'Password', controller: _passwordController, isPassword: true),
            
            _buildSectionTitle('Role & Type'),
            _buildDropdown(label: 'Role', value: _selectedRole, items: _roles, onChanged: (val) => setState(() => _selectedRole = val!)),
            _buildDropdown(label: 'Type', value: _selectedType, items: _types, onChanged: (val) => setState(() => _selectedType = val!)),
            
            _buildSectionTitle('Financial'),
            _buildTextField(label: 'Monthly Salary (e.g., 500)', controller: _salaryController, keyboardType: const TextInputType.numberWithOptions(decimal: true)),

            _buildSectionTitle('Standard Schedule'),
            const SizedBox(height: 10),
            _buildDaySelector(),
            const SizedBox(height: 20),
            _buildTimePickerRow(label: 'From:', time: _standardStartTime, onSelectTime: () => _selectTime(context, isStartTime: true)),
            _buildTimePickerRow(label: 'To:', time: _standardEndTime, onSelectTime: () => _selectTime(context, isStartTime: false)),
            const SizedBox(height: 20),

            _buildCustomSchedulesSection(),
            const SizedBox(height: 20),

            _buildSectionTitle('Assigned Location'),
            _buildTextField(label: 'Location Name (e.g., Main Office)', controller: _locationNameController),
            _buildTextField(label: 'Latitude', controller: _latitudeController, keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true)),
            _buildTextField(label: 'Longitude', controller: _longitudeController, keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true)),

            const SizedBox(height: 40),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
              ),
              onPressed: _isLoading ? null : _saveUser,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Add User', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Padding(
     padding: const EdgeInsets.only(top: 20.0, bottom: 8.0),
     child: Text(title, style: TextStyle(fontSize: 18, color: Colors.grey[800], fontWeight: FontWeight.bold)),
   );

  Widget _buildTextField({required String label, required TextEditingController controller, bool isPassword = false, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 16)),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: keyboardType,
          decoration: InputDecoration(filled: true, fillColor: Colors.grey[200], border: OutlineInputBorder(borderRadius: BorderRadius.circular(50), borderSide: BorderSide.none)),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'This field cannot be empty';
            }
            if (keyboardType == TextInputType.emailAddress && !value.contains('@')) {
              return 'Please enter a valid email';
            }
            if(isPassword && value.length < 6){
              return 'Password must be at least 6 characters';
            }
            if(keyboardType == const TextInputType.numberWithOptions(decimal: true) && double.tryParse(value) == null) {
              return 'Please enter a valid number';
            }
            if(keyboardType == const TextInputType.numberWithOptions(decimal: true, signed: true) && double.tryParse(value) == null) {
              return 'Please enter a valid number';
            }
            return null;
          },
        ),
      ]),
    );
  }

  Widget _buildDropdown({required String label, required String value, required List<String> items, required ValueChanged<String?> onChanged}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 16)),
        const SizedBox(height: 5),
        DropdownButtonFormField<String>(
          value: value,
          items: items.map((item) => DropdownMenuItem<String>(value: item, child: Text(item))).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(filled: true, fillColor: Colors.grey[200], border: OutlineInputBorder(borderRadius: BorderRadius.circular(50), borderSide: BorderSide.none)),
        ),
      ]),
    );
  }

  Widget _buildDaySelector() {
    return SizedBox(
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: _daysOfWeek.map((day) {
          final isSelected = _selectedDays.contains(day);
          return GestureDetector(
            onTap: () => setState(() => isSelected ? _selectedDays.remove(day) : _selectedDays.add(day)),
            child: CircleAvatar(
              radius: 22,
              backgroundColor: isSelected ? const Color(0xFFDAC844) : Colors.grey[200],
              child: Text(day, style: TextStyle(color: isSelected ? Colors.white : Colors.grey[600], fontWeight: FontWeight.bold)),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTimePickerRow({required String label, required TimeOfDay time, required VoidCallback onSelectTime}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(children: [
        Text(label, style: TextStyle(fontSize: 16, color: Colors.grey[700], fontWeight: FontWeight.bold)),
        const SizedBox(width: 10),
        InkWell(onTap: onSelectTime, child: const Icon(Icons.access_time, color: Colors.grey)),
        const SizedBox(width: 10),
        InkWell(onTap: onSelectTime, child: Text(time.format(context), style: const TextStyle(fontSize: 16, color: Colors.blue, fontWeight: FontWeight.bold))),
      ]),
    );
  }
  
  Widget _buildCustomSchedulesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Custom Schedules (Optional)'),
        const SizedBox(height: 10),
        InkWell(
          onTap: _addCustomSchedule,
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(15)),
            child: const Center(child: Text('+ Add a Custom Schedule', style: TextStyle(fontWeight: FontWeight.bold))),
          ),
        ),
        const SizedBox(height: 15),
        ..._customSchedules.asMap().entries.map((entry) {
          int idx = entry.key;
          CustomScheduleEntity schedule = entry.value;

          final allDaysSet = _daysOfWeek.toSet();
          final otherUsedDays = _customSchedules.where((s) => s != schedule).map((s) => s.day).toSet();
          final availableDaysList = allDaysSet.difference(otherUsedDays).toList()..sort((a, b) => _daysOfWeek.indexOf(a).compareTo(_daysOfWeek.indexOf(b)));

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(15)),
            child: Column(children: [
              Row(children: [
                const Text('Day:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 15),
                DropdownButton<String>(
                  value: schedule.day,
                  items: availableDaysList.map((day) => DropdownMenuItem(value: day, child: Text(day))).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                         _customSchedules[idx] = CustomScheduleEntity(day: val, startTime: schedule.startTime, endTime: schedule.endTime);
                      });
                    }
                  },
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.red[400]),
                  onPressed: () => setState(() => _customSchedules.removeAt(idx)),
                ),
              ]),
              _buildTimePickerRow(label: 'From:', time: schedule.startTime, onSelectTime: () => _selectTime(context, isStartTime: true, scheduleIndex: idx)),
              _buildTimePickerRow(label: 'To:', time: schedule.endTime, onSelectTime: () => _selectTime(context, isStartTime: false, scheduleIndex: idx)),
            ]),
          );
        }),
      ],
    );
  }
}