import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/rental.dart';
import '../models/vehicle.dart';
import '../models/vehicle_type.dart';
import '../settings/currency_controller.dart';
import '../theme/app_theme.dart';

const _whatsappGreen = Color(0xFF25D366);
const _ridrRed = PdfColor.fromInt(0xFFD62828);

// Placeholder demo link — swap for the real Play Store listing later.
const _playStoreDemoLink = 'www.google.com';

const List<String> _termsAndConditions = [
  'The customer must return the vehicle in the same condition as received, normal wear and tear excepted.',
  'The customer is responsible for any traffic fines, challans, or penalties incurred during the rental period.',
  'Fuel/charge level must be maintained or restored to the level agreed at pickup.',
  'The security deposit is refundable, subject to inspection of the vehicle at the time of return.',
  'Any damage caused to the vehicle during the rental period will be assessed and charged to the customer.',
  'The vehicle must not be used for illegal purposes, racing, or sub-rented to a third party.',
  'The customer confirms they hold a valid driving licence for this category of vehicle.',
  'A late return beyond the agreed end time may attract additional charges as per the shop\'s policy.',
  'The shop is not liable for personal belongings left in the vehicle during the rental period.',
  'This agreement is governed by applicable local laws.',
];

String _formatAgreementDuration(Duration duration) {
  final minutes = duration.inMinutes;
  if (minutes <= 0) return '0 minutes';
  final hours = minutes ~/ 60;
  final remainingMinutes = minutes % 60;
  if (hours == 0) return '$remainingMinutes minutes';
  if (remainingMinutes == 0) return '$hours ${hours == 1 ? 'hour' : 'hours'}';
  return '$hours ${hours == 1 ? 'hour' : 'hours'} $remainingMinutes minutes';
}

pw.Widget _sectionTitle(String title) => pw.Text(
      title,
      style: const pw.TextStyle(
          fontSize: 12.5, fontWeight: pw.FontWeight.bold, color: _ridrRed),
    );

pw.Widget _kvTable(Map<String, String> entries) => pw.Table(
      columnWidths: const {
        0: pw.FlexColumnWidth(1),
        1: pw.FlexColumnWidth(1.4),
      },
      children: [
        for (final e in entries.entries)
          pw.TableRow(children: [
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 3),
              child: pw.Text(e.key,
                  style: const pw.TextStyle(
                      fontSize: 10, color: PdfColors.grey700)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 3),
              child: pw.Text(e.value,
                  style: const pw.TextStyle(
                      fontSize: 10, fontWeight: pw.FontWeight.bold)),
            ),
          ]),
      ],
    );

pw.Widget _termsColumn(List<String> terms, int startIndex) => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < terms.length; i++)
          pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 3),
            child: pw.Text('${startIndex + i}. ${terms[i]}',
                style: const pw.TextStyle(fontSize: 7.8, lineSpacing: 1.1)),
          ),
      ],
    );

/// Builds the rental agreement PDF for [rental]/[vehicle] and saves it to
/// the app's documents directory, returning the file.
Future<File> buildAgreementPdf({
  required Rental rental,
  required Vehicle vehicle,
}) async {
  final prefs = await SharedPreferences.getInstance();
  final ownerName = prefs.getString('owner_name') ?? '';
  final shopName = prefs.getString('shop_name') ?? 'Your shop';
  final currency = CurrencyController.instance.currency.value;
  final dateFormat = DateFormat('d MMM yyyy, h:mm a');

  final regularFont = pw.Font.ttf(
      await rootBundle.load('assets/fonts/NotoSans-Regular.ttf'));
  final boldFont =
      pw.Font.ttf(await rootBundle.load('assets/fonts/NotoSans-Bold.ttf'));
  final logoImage = pw.MemoryImage(
      (await rootBundle.load('assets/images/ridr_logo.png'))
          .buffer
          .asUint8List());

  final termsLeft = _termsAndConditions.sublist(0, 5);
  final termsRight = _termsAndConditions.sublist(5);

  final doc = pw.Document(
    theme: pw.ThemeData.withFont(base: regularFont, bold: boldFont),
  );
  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(28),
      build: (ctx) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Header
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Image(logoImage, height: 26),
                  pw.SizedBox(height: 3),
                  pw.Text('Making vehicle rentals effortless.',
                      style: const pw.TextStyle(
                          fontSize: 7.5,
                          color: PdfColors.grey700,
                          fontStyle: pw.FontStyle.italic)),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('Vehicle Rental Agreement',
                      style: const pw.TextStyle(
                          fontSize: 11, fontWeight: pw.FontWeight.bold)),
                  pw.Text(dateFormat.format(DateTime.now()),
                      style: const pw.TextStyle(
                          fontSize: 8, color: PdfColors.grey700)),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 6),
          pw.Divider(thickness: 1, color: _ridrRed),
          pw.SizedBox(height: 6),
          pw.Text(
            ownerName.isNotEmpty
                ? '$shopName • Managed by $ownerName'
                : shopName,
            style: const pw.TextStyle(
                fontSize: 11, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),

          // Vehicle + Customer, side by side
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('Vehicle details'),
                    _kvTable({
                      'Type': vehicle.type.label,
                      'Model': vehicle.model,
                      'Reg. number': vehicle.number,
                      'Colour': vehicle.colour,
                    }),
                  ],
                ),
              ),
              pw.SizedBox(width: 16),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('Customer details'),
                    _kvTable({
                      'Name': rental.customerName,
                      'Age': '${rental.age}',
                      'Contact': rental.contactNumber,
                      'Govt. ID': rental.aadharNumber,
                    }),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 10),

          // Trip window + Charges, side by side
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('Trip window'),
                    _kvTable({
                      'Start': dateFormat.format(rental.startDateTime),
                      'End': dateFormat.format(rental.endDateTime),
                      'Duration': _formatAgreementDuration(
                          rental.endDateTime.difference(rental.startDateTime)),
                    }),
                  ],
                ),
              ),
              pw.SizedBox(width: 16),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('Charges'),
                    _kvTable({
                      'Rent charge':
                          '${currency.symbol}${rental.rentCharge.toStringAsFixed(0)}',
                      'Deposit':
                          '${currency.symbol}${rental.deposit.toStringAsFixed(0)}',
                      'Total':
                          '${currency.symbol}${(rental.rentCharge + rental.deposit).toStringAsFixed(0)}',
                    }),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 10),

          _sectionTitle('Terms & conditions'),
          pw.SizedBox(height: 3),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(child: _termsColumn(termsLeft, 1)),
              pw.SizedBox(width: 14),
              pw.Expanded(
                  child: _termsColumn(termsRight, termsLeft.length + 1)),
            ],
          ),
          pw.SizedBox(height: 10),

          _sectionTitle('Customer acceptance'),
          pw.SizedBox(height: 4),
          pw.Text(
            'By signing below, ${rental.customerName} confirms they have read, understood, and agree to the terms of this rental agreement.',
            style: const pw.TextStyle(fontSize: 8.5),
          ),
          pw.SizedBox(height: 6),
          pw.SizedBox(height: 30),
          pw.Divider(thickness: 0.6),
          pw.Text('Customer signature',
              style:
                  const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700)),

          pw.Spacer(),
          pw.Divider(),
          pw.Text(
            'Generated with Ridr — making vehicle rentals effortless. Download now: $_playStoreDemoLink',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
          ),
        ],
      ),
    ),
  );

  final dir = await getApplicationDocumentsDirectory();
  final fileName =
      'agreement_${rental.contactNumber}_${DateTime.now().millisecondsSinceEpoch}.pdf';
  final file = File('${dir.path}/$fileName');
  await file.writeAsBytes(await doc.save());
  return file;
}

/// Shows a bottom sheet that generates the rental agreement PDF and shares
/// it through the OS share sheet — WhatsApp, email, SMS, and more all
/// appear there as options, since there's no way to pre-target a specific
/// WhatsApp contact with a file attachment the way a plain text message
/// can be.
Future<void> showSendAgreementSheet(
  BuildContext context, {
  required Rental rental,
  required Vehicle vehicle,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => _AgreementSheet(rental: rental, vehicle: vehicle),
  );
}

class _AgreementSheet extends StatefulWidget {
  final Rental rental;
  final Vehicle vehicle;
  const _AgreementSheet({required this.rental, required this.vehicle});

  @override
  State<_AgreementSheet> createState() => _AgreementSheetState();
}

class _AgreementSheetState extends State<_AgreementSheet> {
  bool _busy = false;

  Future<void> _share() async {
    setState(() => _busy = true);
    final file = await buildAgreementPdf(
      rental: widget.rental,
      vehicle: widget.vehicle,
    );
    if (!mounted) return;
    Navigator.of(context).pop();
    await SharePlus.instance.share(ShareParams(
      files: [XFile(file.path)],
      text:
          'Rental agreement for ${widget.rental.customerName} — ${widget.vehicle.model} (${widget.vehicle.number}).',
    ));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Rental agreement',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              'Generate the trip agreement and share it with the customer.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: _busy ? null : _share,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _whatsappGreen.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: _whatsappGreen.withValues(alpha: 0.35)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: _whatsappGreen.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _busy
                          ? const Padding(
                              padding: EdgeInsets.all(11),
                              child: CircularProgressIndicator(
                                  strokeWidth: 2.4, color: _whatsappGreen),
                            )
                          : const Icon(Icons.ios_share_rounded,
                              color: _whatsappGreen),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Share agreement PDF',
                              style: TextStyle(
                                  fontWeight: FontWeight.w800, fontSize: 15)),
                          const SizedBox(height: 2),
                          Text('WhatsApp, email, and more',
                              style:
                                  TextStyle(color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded,
                        color: _whatsappGreen),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
