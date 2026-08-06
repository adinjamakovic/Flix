import 'package:date_picker_plus/date_picker_plus.dart';
import 'package:flix_desktop/models/clash.dart';
import 'package:flix_desktop/models/picked_image.dart';
import 'package:flix_desktop/providers/clash_provider.dart';
import 'package:flix_desktop/utils/utils_widgets.dart';
import 'package:flix_desktop/widgets/image_input.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ClashDetails extends StatefulWidget {
  const ClashDetails({ super.key, this.clash });

  final Clash? clash;

  @override
  _ClashDetailsState createState() => _ClashDetailsState();
}

class _ClashDetailsState extends State<ClashDetails> {

  static const int _nameMaxLength = 150;
  static const int _descriptionMaxLegth = 500;

  // A clash can only be scheduled from today onwards; the calendar is
  // date-only, so the upper bound is a plain date too.
  static final DateTime _maxSelectableDate = DateTime(2030, 12, 31);

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime _startDate = DateTime.now().toUtc();
  DateTime _endDate = DateTime.now().add(const Duration(days: 4));

  late ClashProvider _clashProvider;

  PickedImage? _clashImage;
  bool _isSaving = false;

  bool get _isNewClash => widget.clash?.id == null;

  @override
  void initState() {
    super.initState();

    _nameController.text = widget.clash?.name ?? '';
    _descriptionController.text = widget.clash?.description ?? '';
    _startDate = widget.clash?.startDate ?? DateTime.now().toUtc();
    _endDate = widget.clash?.endDate ?? DateTime.now().add(const Duration(days: 4));

    _clashProvider = context.read<ClashProvider>();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isNewClash ? "New Clash" : "Update clash: ${widget.clash?.name}"
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(32, 8, 32, 32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: _buildForm(),
                ),  
              )
            ),
        )
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  label: "Name",
                  controller: _nameController,
                  validator: (value) =>
                    requiredValidator(value) ??
                    maxLengthValidator(value, _nameMaxLength)
                )
              ),
              const SizedBox(width: 16),
              Expanded(child: _buildDateRangeField())
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: "Description", 
            controller: _descriptionController, 
            maxLines: 4,
            validator: (value) =>
             requiredValidator(value) ??
             maxLengthValidator(value, _descriptionMaxLegth)),
          const SizedBox(height: 16),
          ImageInput(
            label: "Clash Banner",
            helperText: "JPG, PNG, GIF or WEBP, up to 5MB",
            placeholderIcon: Icons.landscape_outlined,
            currentImageUrl: widget.clash?.bannerImage,
            enabled: !_isSaving,
            shape: ImageInputShape.rectangle,
            size: 400,
            onChanged: (image) => _clashImage = image
          ),
          const SizedBox(height: 12,),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _isSaving ? null : () => Navigator.pop(context), 
                child: const Text("Cancel")
              ),
              const SizedBox(width: 12,),
              ElevatedButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                  ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2,),
                  )
                  : Text(_isNewClash ? "Create Clash" : "Save changes")
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildDateRangeField() {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel("Start and end date"),
        const SizedBox(height: 6),
        FormField<DateTimeRange>(
          initialValue: DateTimeRange(start: _startDate, end: _endDate),
          validator: (range) =>
              (range == null || range.end.isBefore(range.start))
                  ? "The end date must come after the start date"
                  : null,
          builder: (field) => InkWell(
            onTap: _isSaving ? null : () => _pickDateRange(field),
            child: InputDecorator(
              decoration: InputDecoration(
                errorText: field.errorText,
                suffixIcon: Icon(
                  Icons.date_range_outlined,
                  size: 20,
                  color: colors.onSurfaceVariant,
                ),
              ),
              child: Text(
                "${formatDate(_startDate)}  -  ${formatDate(_endDate)}",
                style: TextStyle(color: colors.onSurface, fontSize: 14),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickDateRange(FormFieldState<DateTimeRange> field) async {
    final DateTime today = DateUtils.dateOnly(DateTime.now());

    final DateTimeRange? range = await showRangePickerDialog(
      context: context,
      minDate: today,
      maxDate: _maxSelectableDate,
      // An existing clash may have started before today, which the calendar
      // cannot show, so it opens with nothing selected instead.
      selectedRange: _startDate.isBefore(today)
          ? null
          : DateTimeRange(start: _startDate, end: _endDate),
    );

    if (range == null || !mounted) return;

    setState(() {
      // The calendar only returns dates, so the times already on the clash are
      // carried over instead of being reset to midnight.
      _startDate = _withTimeOf(range.start, _startDate);
      _endDate = _withTimeOf(range.end, _endDate);
    });

    field.didChange(DateTimeRange(start: _startDate, end: _endDate));
  }

  DateTime _withTimeOf(DateTime date, DateTime time) {
    final DateTime combined = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    return time.isUtc ? combined.toUtc() : combined;
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(label),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          enabled: !_isSaving,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          style: TextStyle(color: colors.onSurface, fontSize: 14),
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String label) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Text(
      label,
      style: TextStyle(
        color: colors.onSurfaceVariant,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Future<void> _save() async {
    if(!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isSaving = true;
    });

    final Map<String, dynamic> fields = {
      "name": _nameController.text.trim(),
      "description": _descriptionController.text.trim(),
      "startDate": _startDate.toIso8601String(),
      "endDate": _endDate.toIso8601String(),
    };

    final Map<String, PickedImage> files = {"bannerImage": ?_clashImage};

    try {
      if(_isNewClash) {
        await _clashProvider.insert(fields, files: files);
      } else {
        await _clashProvider.update(widget.clash!.id!, fields, files: files);
      }

      if(!mounted) return;
      Navigator.pop(context, true);
    } on Exception catch (e) {
      if(!mounted) return;

      setState(() {
        _isSaving = false;
      });
      alertBox(context, "Error", e.toString());
    }
  }
}