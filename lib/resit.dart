import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:google_fonts/google_fonts.dart';
import '../Rekod_Cawangan/rekodCawangan.dart';
import '../SenaraiBarang.dart';
import 'package:string_capitalize/string_capitalize.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'dart:ui' as ui;
import 'package:image/image.dart' as imagePkg;
import '../DocumentHelper.dart';
import '../databaseLocal.dart';

final fontFamily = font;

class PdfInvoicePelanggan {
  static Future<File> generate(
    PdfColor color,
    int selectIndex,
    rekodPelanggan current,
  ) async {
    final pdf = pw.Document();
    final iconImage = (await rootBundle.load(
      'image/grayBlack_icon.png',
    )).buffer.asUint8List();
    final iconImageQR = (await rootBundle.load(
      'image/sattay_Desa_QR.png',
    )).buffer.asUint8List();

    List<rekodPesananPelanggan> rekodMenu = List<rekodPesananPelanggan>.from(
      current.orderMenu,
    ).toList();
    String pdfFile = '${current.nama} Resit';
    int runnerID = current.runner;
    String runner = rekod_Runner
        .elementAt(rekod_Runner.indexWhere((e) => e.id == runnerID))
        .nama;
    String invoice = current.noBil;
    String tarikhOrder = current.tarikhOrder == ""
        ? DateFormat('dd/MM/yyyy').format(DateTime.now())
        : current.tarikhOrder;
    if (current.tarikhOrder.isEmpty) {
      current.tarikhOrder = tarikhOrder;
      saveDataLocal();
      updateStok(current.tarikh);
    }
    if (invoice.isEmpty) {
      int totalOrder = rekod_Pelanggan
          .where((pelanggan) => pelanggan.tarikh == tarikhOrder)
          .length;
      invoice = 'US${tarikhOrder.replaceAll("/", "")}$totalOrder';
    }
    runner = runner.isEmpty
        ? "Self Pickup"
        : (() {
            final index = rekod_Runner.indexWhere(
              (element) => element.nama == runner,
            );

            if (index == -1) return runner;

            final phone = rekod_Runner[index].telefon;
            return '$runner ($phone)';
          })();
    pdf.addPage(
      pw.MultiPage(
        margin: pw.EdgeInsets.all(10),
        pageFormat: PdfPageFormat.a4,
        header: (context) {
          return pw.Column(
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              pw.Row(
                children: [
                  // pw.Image(
                  //   pw.MemoryImage(iconImage),
                  //   height: 75,
                  //   width: 75,
                  // ),
                  pw.Column(
                    mainAxisSize: pw.MainAxisSize.min,
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Sattay Ussop',
                        style: pw.TextStyle(
                          fontSize: 20.0,
                          fontWeight: pw.FontWeight.bold,
                          color: color,
                          font: fontFamily,
                        ),
                      ),
                      pw.Text(
                        'No 129,Persiaran Pinji Selatan 4,\nTaman Desa Pelancongan \n31500 Lahat Perak',
                        style: pw.TextStyle(
                          fontSize: 15.0,
                          color: color,
                          font: fontFamily,
                        ),
                      ),
                    ],
                  ),
                  pw.Spacer(),
                  pw.Column(
                    mainAxisSize: pw.MainAxisSize.min,
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'IP0219617-M',
                        style: pw.TextStyle(
                          fontSize: 15.0,
                          color: color,
                          font: fontFamily,
                        ),
                      ),
                      pw.Text(
                        '016-4484143',
                        style: pw.TextStyle(
                          fontSize: 15.0,
                          color: color,
                          font: fontFamily,
                        ),
                      ),
                      pw.Text(
                        'ussop.satay@gmail.com',
                        style: pw.TextStyle(
                          fontSize: 15.0,
                          color: color,
                          font: font,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.Divider(),
            ],
          );
        },
        build: (context) {
          return <pw.Widget>[
            pw.Column(
              mainAxisSize: pw.MainAxisSize.min,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  children: [
                    pw.Text(
                      'No Resit : ',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        color: color,
                        font: fontFamily,
                      ),
                    ),
                    pw.Flexible(
                      child: pw.Text(
                        invoice,
                        style: pw.TextStyle(color: color, font: fontFamily),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 1 * PdfPageFormat.mm),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Tarikh   : ',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        color: color,
                        font: fontFamily,
                      ),
                    ),
                    pw.Text(
                      '${current.hari}, ${current.tarikh} ${current.masa}',
                      style: pw.TextStyle(color: color, font: fontFamily),
                    ),
                  ],
                ),
                pw.SizedBox(height: 1 * PdfPageFormat.mm),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Nama     : ',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        color: color,
                        font: fontFamily,
                      ),
                    ),
                    pw.Text(
                      current.nama.capitalizeEach(),
                      style: pw.TextStyle(color: color, font: fontFamily),
                    ),
                  ],
                ),
                pw.SizedBox(height: 1 * PdfPageFormat.mm),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Telefon  : ',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        color: color,
                        font: fontFamily,
                      ),
                    ),
                    pw.Text(
                      current.telefon,
                      style: pw.TextStyle(color: color, font: fontFamily),
                    ),
                  ],
                ),
                pw.SizedBox(height: 1 * PdfPageFormat.mm),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Alamat   : ',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        color: color,
                        font: fontFamily,
                      ),
                    ),
                    pw.Flexible(
                      child: pw.Text(
                        current.alamat.capitalizeEach(),
                        style: pw.TextStyle(color: color, font: fontFamily),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 1 * PdfPageFormat.mm),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Text(
                  'Runner: ',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    color: color,
                    font: fontFamily,
                  ),
                ),
                pw.Flexible(
                  child: pw.Text(
                    runner,
                    style: pw.TextStyle(color: color, font: fontFamily),
                    textAlign: pw.TextAlign.right,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 1 * PdfPageFormat.mm),

            ///
            /// PDF Table Create
            ///
            pw.Table(
              border: pw.TableBorder.all(),
              columnWidths: <int, pw.TableColumnWidth>{
                0: pw.FlexColumnWidth(),
                1: pw.FixedColumnWidth(70),
                2: pw.FixedColumnWidth(60),
                3: pw.FixedColumnWidth(80),
              },
              children: [
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8.0),
                      child: pw.Text(
                        'Produk',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8.0),
                      child: pw.Text(
                        'Kuantiti',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8.0),
                      child: pw.Text(
                        'Harga Seunit',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8.0),
                      child: pw.Text(
                        'Jumlah',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            pw.ListView.builder(
              itemCount: rekodMenu.length,
              itemBuilder: (pw.Context context, int index) {
                rekodPesananPelanggan current = rekodMenu.elementAt(index);
                String currentPesanan = current.pesanan.toStringAsFixed(1);
                if (currentPesanan.contains(".0")) {
                  currentPesanan = current.pesanan.toStringAsFixed(0);
                }
                return pw.Table(
                  border: pw.TableBorder.all(),
                  columnWidths: <int, pw.TableColumnWidth>{
                    0: pw.FlexColumnWidth(),
                    1: pw.FixedColumnWidth(70),
                    2: pw.FixedColumnWidth(60),
                    3: pw.FixedColumnWidth(80),
                  },
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8.0),
                          child: pw.Text(
                            current.jenis,
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.normal,
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8.0),
                          child: pw.Text(
                            currentPesanan,
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.normal,
                            ),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8.0),
                          child: pw.Text(
                            money(current.Harga),
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.normal,
                            ),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8.0),
                          child: pw.Text(
                            money(current.Jumlah),
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.normal,
                            ),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            pw.Divider(),
            pw.Container(
              alignment: pw.Alignment.centerRight,
              child: pw.Row(
                children: [
                  pw.Spacer(flex: 3),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Row(
                          children: [
                            pw.Expanded(
                              child: pw.Text(
                                'Jumlah Keseluruhan',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  color: color,
                                  font: fontFamily,
                                ),
                              ),
                            ),
                            pw.Text(
                              'RM ${money(current.jumlahBayaran)}',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                color: color,
                                font: fontFamily,
                              ),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 2 * PdfPageFormat.mm),
                        pw.Row(
                          children: [
                            pw.Expanded(
                              child: pw.Text(
                                'Deposit',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  color: color,
                                  font: fontFamily,
                                ),
                              ),
                            ),
                            pw.Text(
                              'RM ${money(current.BayaranPendahuluan)}',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                color: color,
                                font: fontFamily,
                              ),
                            ),
                          ],
                        ),
                        pw.Divider(),
                        pw.Row(
                          children: [
                            pw.Expanded(
                              child: pw.Text(
                                'Baki Bayaran',
                                style: pw.TextStyle(
                                  fontSize: 14.0,
                                  fontWeight: pw.FontWeight.bold,
                                  color: color,
                                  font: fontFamily,
                                ),
                              ),
                            ),
                            pw.Text(
                              'RM ${money(current.baki)}',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                color: color,
                                font: fontFamily,
                              ),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 2 * PdfPageFormat.mm),
                        pw.Container(height: 1, color: PdfColors.grey400),
                        pw.SizedBox(height: 0.5 * PdfPageFormat.mm),
                        pw.Container(height: 1, color: PdfColors.grey400),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ];
        },
        footer: (context) {
          return pw.Column(
            mainAxisSize: pw.MainAxisSize.min,
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Divider(),
              pw.SizedBox(height: 1 * PdfPageFormat.mm),
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Image(pw.MemoryImage(iconImageQR), height: 72, width: 72),
                  pw.Column(
                    mainAxisSize: pw.MainAxisSize.min,
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Maklumat Pembayaran',
                        style: pw.TextStyle(
                          fontSize: 14.0,
                          fontWeight: pw.FontWeight.bold,
                          color: color,
                          font: fontFamily,
                        ),
                      ),
                      pw.SizedBox(height: 1 * PdfPageFormat.mm),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Nama Bank  : ',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              color: color,
                              font: fontFamily,
                            ),
                          ),
                          pw.Text(
                            'Maybank',
                            style: pw.TextStyle(color: color, font: fontFamily),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 1 * PdfPageFormat.mm),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Nama Akaun : ',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              color: color,
                              font: fontFamily,
                            ),
                          ),
                          pw.Text(
                            'SATTAY DESA',
                            style: pw.TextStyle(color: color, font: font),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 1 * PdfPageFormat.mm),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.start,
                        children: [
                          pw.Text(
                            'No Akaun   : ',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              color: color,
                              font: fontFamily,
                            ),
                          ),
                          pw.Text(
                            '558033625191',
                            style: pw.TextStyle(color: color, font: font),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
    return FileHandleApi.saveDocument(name: '$pdfFile.pdf', pdf: pdf);
  }
}

class PdfSlipGaji {
  static Future<File> generate(PdfColor color, String nama, bool epf) async {
    final pdf = pw.Document();

    num jumlahHarian = 0.0;
    num jumlahSimpan = 0.0;
    num ambil = 0.0;
    String tarikh = "";
    int selectIndex = rekod_Pekerja.indexWhere(
      (element) => element.username == nama,
    );
    if (selectIndex == -1) {
      return Future.error("Pekerja tidak dijumpai");
    }
    rekodPekerja current = rekod_Pekerja[selectIndex];
    int id = current.id;
    String namaPenuh = current.namaPenuh;
    String ic = current.ic;
    String bank = current.bank;
    final List<rekodAmbilGaji> rekodAmbil = List<rekodAmbilGaji>.from(
      current.rekodAmbil,
    ).toList();

    // Jumlah ambil
    ambil = rekodAmbil.fold(0.0, (total, item) => total + item.jumlah);

    // Rekod gaji
    for (final current in rekod_Gaji) {
      // Set tarikh sekali sahaja
      if (tarikh.isEmpty) {
        final tempDate = DateFormat(
          "dd/MM/yyyy",
        ).parse(current.tarikh.toString());

        tarikh = DateFormat('MMMM yyyy').format(tempDate);
      }

      final rekod = List<rekodGajiDetail>.from(current.rekod).toList();

      final currentRekod = rekod.cast<rekodGajiDetail?>().firstWhere(
        (element) => element?.pekerja_id == id,
        orElse: () => null,
      );

      // Skip jika tiada rekod pekerja
      if (currentRekod == null) continue;

      jumlahHarian += currentRekod.harian;
      jumlahSimpan += currentRekod.simpan;
    }

    // Visibility
    final bool showHarian = jumlahHarian > 0;
    final bool showSimpan = jumlahSimpan > 0;
    final bool showAmbil = ambil > 0;

    // Jumlah pendapatan
    final num jumlahPendapatan = jumlahSimpan + jumlahHarian;

    // KWSP
    final KWSP = epf ? (jumlahSimpan * 0.11).round() : 0;
    final KWSPMajikan = epf ? (jumlahSimpan * 0.13).round() : 0;

    // Potongan & gaji
    final num jumlahPotongan = ambil + KWSP;
    final num bakiGaji = jumlahSimpan - jumlahPotongan;
    final num gajiBersih = jumlahPendapatan - jumlahPotongan;
    print("tarikh >> $tarikh >> $jumlahPendapatan");
    String pdfFile = '$namaPenuh Slip Gaji';
    pdf.addPage(
      pw.MultiPage(
        margin: pw.EdgeInsets.all(10),
        pageFormat: PdfPageFormat.a4,
        orientation: pw.PageOrientation.landscape,
        header: (context) {
          return pw.Column(
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              pw.Row(
                children: [
                  pw.Column(
                    mainAxisSize: pw.MainAxisSize.min,
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Sattay Ussop',
                        style: pw.TextStyle(
                          fontSize: 20.0,
                          fontWeight: pw.FontWeight.bold,
                          color: color,
                          font: fontFamily,
                        ),
                      ),
                      pw.Flexible(
                        child: pw.Text(
                          '(IP0219617-M)',
                          style: pw.TextStyle(
                            fontSize: 14.0,
                            fontWeight: pw.FontWeight.bold,
                            color: color,
                            font: fontFamily,
                          ),
                        ),
                      ),
                    ],
                  ),
                  pw.Spacer(),
                  pw.Column(
                    mainAxisSize: pw.MainAxisSize.min,
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(
                        'Slip Gaji',
                        style: pw.TextStyle(color: color, font: fontFamily),
                      ),
                      pw.Text(
                        tarikh,
                        style: pw.TextStyle(color: color, font: fontFamily),
                      ),
                    ],
                  ),
                ],
              ),
              pw.Divider(),
            ],
          );
        },
        build: (context) {
          return <pw.Widget>[
            pw.Column(
              mainAxisSize: pw.MainAxisSize.min,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Nama            : ',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        color: color,
                        font: fontFamily,
                      ),
                    ),
                    pw.Flexible(
                      child: pw.Text(
                        namaPenuh.capitalizeEach(),
                        style: pw.TextStyle(color: color, font: fontFamily),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 1 * PdfPageFormat.mm),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Kad Pengenalan  : ',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        color: color,
                        font: fontFamily,
                      ),
                    ),
                    pw.Text(
                      ic,
                      style: pw.TextStyle(color: color, font: fontFamily),
                    ),
                  ],
                ),
                pw.SizedBox(height: 1 * PdfPageFormat.mm),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Bank            : ',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        color: color,
                        font: fontFamily,
                      ),
                    ),
                    pw.Text(
                      bank.capitalizeEach(),
                      style: pw.TextStyle(color: color, font: fontFamily),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 1 * PdfPageFormat.mm),
            pw.Table(
              border: pw.TableBorder.all(),
              columnWidths: <int, pw.TableColumnWidth>{
                0: pw.FlexColumnWidth(),
                1: pw.FlexColumnWidth(),
              },
              children: [
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8.0),
                      child: pw.Text(
                        'Pendapatan',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8.0),
                      child: pw.Text(
                        'Potongan',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            pw.Table(
              border: pw.TableBorder.all(),
              columnWidths: <int, pw.TableColumnWidth>{
                0: pw.FlexColumnWidth(),
                1: pw.FlexColumnWidth(),
                2: pw.FlexColumnWidth(),
                3: pw.FlexColumnWidth(),
              },
              children: [
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8.0),
                      child: pw.Text(
                        'Butiran',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8.0),
                      child: pw.Text(
                        'Jumlah (RM)',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8.0),
                      child: pw.Text(
                        'Butiran',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8.0),
                      child: pw.Text(
                        'Jumlah (RM)',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            pw.Table(
              border: pw.TableBorder.all(),
              columnWidths: <int, pw.TableColumnWidth>{
                0: pw.FlexColumnWidth(),
                1: pw.FlexColumnWidth(),
                2: pw.FlexColumnWidth(),
                3: pw.FlexColumnWidth(),
              },
              children: [
                pw.TableRow(
                  children: [
                    pw.Container(
                      height: 100,
                      child: pw.Column(
                        children: [
                          showSimpan
                              ? pw.Padding(
                                  padding: pw.EdgeInsets.all(8.0),
                                  child: pw.Text(
                                    'Gaji Simpan',
                                    style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.normal,
                                      color: color,
                                      font: fontFamily,
                                    ),
                                  ),
                                )
                              : pw.SizedBox(height: 0),
                          showHarian
                              ? pw.Padding(
                                  padding: pw.EdgeInsets.all(8.0),
                                  child: pw.Text(
                                    'Gaji Harian',
                                    style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.normal,
                                      color: color,
                                      font: fontFamily,
                                    ),
                                  ),
                                )
                              : pw.SizedBox(height: 0),
                        ],
                      ),
                    ),
                    pw.Container(
                      height: 100,
                      child: pw.Column(
                        children: [
                          showSimpan
                              ? pw.Padding(
                                  padding: pw.EdgeInsets.all(8.0),
                                  child: pw.Text(
                                    money(jumlahSimpan),
                                    style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.normal,
                                      color: color,
                                      font: fontFamily,
                                    ),
                                    textAlign: pw.TextAlign.center,
                                  ),
                                )
                              : pw.SizedBox(height: 0),
                          showHarian
                              ? pw.Padding(
                                  padding: pw.EdgeInsets.all(8.0),
                                  child: pw.Text(
                                    money(jumlahHarian),
                                    style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.normal,
                                      color: color,
                                      font: fontFamily,
                                    ),
                                    textAlign: pw.TextAlign.center,
                                  ),
                                )
                              : pw.SizedBox(height: 0),
                        ],
                      ),
                    ),
                    pw.Container(
                      height: 100,
                      child: pw.Column(
                        children: [
                          showAmbil
                              ? pw.Padding(
                                  padding: pw.EdgeInsets.all(8.0),
                                  child: pw.Text(
                                    'Gaji Ambil',
                                    style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.normal,
                                      color: color,
                                      font: fontFamily,
                                    ),
                                    textAlign: pw.TextAlign.center,
                                  ),
                                )
                              : pw.SizedBox(height: 0),
                          epf
                              ? pw.Padding(
                                  padding: pw.EdgeInsets.all(8.0),
                                  child: pw.Text(
                                    'KWSP',
                                    style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.normal,
                                      color: color,
                                      font: fontFamily,
                                    ),
                                    textAlign: pw.TextAlign.center,
                                  ),
                                )
                              : pw.SizedBox(height: 0),
                        ],
                      ),
                    ),
                    pw.Container(
                      height: 100,
                      child: pw.Column(
                        children: [
                          showAmbil
                              ? pw.Padding(
                                  padding: pw.EdgeInsets.all(8.0),
                                  child: pw.Text(
                                    money(ambil),
                                    style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.normal,
                                      color: color,
                                      font: fontFamily,
                                    ),
                                    textAlign: pw.TextAlign.center,
                                  ),
                                )
                              : pw.SizedBox(height: 0),
                          epf
                              ? pw.Padding(
                                  padding: pw.EdgeInsets.all(8.0),
                                  child: pw.Text(
                                    money(KWSP),
                                    style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.normal,
                                      color: color,
                                      font: fontFamily,
                                    ),
                                    textAlign: pw.TextAlign.center,
                                  ),
                                )
                              : pw.SizedBox(height: 0),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            pw.Table(
              border: pw.TableBorder.all(),
              columnWidths: <int, pw.TableColumnWidth>{
                0: pw.FlexColumnWidth(),
                1: pw.FlexColumnWidth(),
                2: pw.FlexColumnWidth(),
                3: pw.FlexColumnWidth(),
              },
              children: [
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8.0),
                      child: pw.Text(
                        'Jumlah Pendapatan (RM)',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8.0),
                      child: pw.Text(
                        money(jumlahPendapatan),
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.normal,
                          color: color,
                          font: fontFamily,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8.0),
                      child: pw.Text(
                        'Jumlah Potongan (RM)',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8.0),
                      child: pw.Text(
                        money(jumlahPotongan),
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            pw.Divider(),
            pw.Container(
              alignment: pw.Alignment.centerRight,
              child: pw.Row(
                children: [
                  pw.Spacer(flex: 3),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        epf
                            ? pw.Row(
                                children: [
                                  pw.Expanded(
                                    child: pw.Text(
                                      'KWSP Majikan (RM)',
                                      style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold,
                                        color: color,
                                        font: fontFamily,
                                      ),
                                    ),
                                  ),
                                  pw.Text(
                                    money(KWSPMajikan),
                                    style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      color: color,
                                      font: fontFamily,
                                    ),
                                  ),
                                ],
                              )
                            : pw.SizedBox(height: 0),
                        epf
                            ? pw.SizedBox(height: 2 * PdfPageFormat.mm)
                            : pw.SizedBox(height: 0),
                        pw.Row(
                          children: [
                            pw.Expanded(
                              child: pw.Text(
                                'Baki Gaji (RM)',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  color: color,
                                  font: fontFamily,
                                ),
                              ),
                            ),
                            pw.Text(
                              money(bakiGaji),
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                color: color,
                                font: fontFamily,
                              ),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 2 * PdfPageFormat.mm),
                        pw.Divider(),
                        pw.Row(
                          children: [
                            pw.Expanded(
                              child: pw.Text(
                                'Gaji Bersih (RM)',
                                style: pw.TextStyle(
                                  fontSize: 17.0,
                                  fontWeight: pw.FontWeight.bold,
                                  color: color,
                                  font: fontFamily,
                                ),
                              ),
                            ),
                            pw.Text(
                              money(gajiBersih),
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                color: color,
                                font: fontFamily,
                              ),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 2 * PdfPageFormat.mm),
                        pw.Container(height: 1, color: PdfColors.grey400),
                        pw.SizedBox(height: 0.5 * PdfPageFormat.mm),
                        pw.Container(height: 1, color: PdfColors.grey400),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ];
        },
      ),
    );
    if (epf) {
      return FileHandleApi.saveDocument(name: '$pdfFile.pdf', pdf: pdf);
    } else {
      return FileHandleApi.saveDocument(
        name: '${pdfFile}nonKWSP.pdf',
        pdf: pdf,
      );
    }
  }
}

class PdfDetailGaji {
  static List<rekodGajiFilter> reloadData(String filterName) {
    List<rekodGajiFilter> rekodGajiFilterDetail = <rekodGajiFilter>[];
    num jumlahHarian = 0.00;
    num JumlahSimpan = 0.00;
    num jumlahGajiAmbil = 0.00;
    for (var index = 0; index < rekod_Gaji.length; index++) {
      rekodGaji gajiList = rekod_Gaji.elementAt(index);
      String tarikh = gajiList.tarikh;
      List<rekodGajiDetail> rekod = List<rekodGajiDetail>.from(
        gajiList.rekod,
      ).toList();
      for (var k = 0; k < rekod.length; k++) {
        rekodGajiDetail current = rekod.elementAt(k);
        String nama = rekod_Pekerja
            .elementAt(
              rekod_Pekerja.indexWhere((e) => e.id == current.pekerja_id),
            )
            .username;
        num harian = current.harian;
        num simpan = current.simpan;
        if (filterName == nama) {
          jumlahHarian = jumlahHarian + harian;
          JumlahSimpan = JumlahSimpan + simpan;
          if (rekodGajiFilterDetail
              .map((item) => item.tarikh)
              .contains(tarikh)) {
            int selectIndex = rekodGajiFilterDetail.indexWhere(
              (element) => element.tarikh == tarikh,
            );

            if (selectIndex >= 0) {
              rekodGajiFilter currentfilter = rekodGajiFilterDetail.elementAt(
                selectIndex,
              );
              currentfilter.harian = currentfilter.harian + harian;
              currentfilter.simpan = currentfilter.simpan + simpan;
            }
          } else {
            rekodGajiFilterDetail.add(
              rekodGajiFilter(tarikh, nama, harian, simpan, 0.00),
            );
          }
        } else if (filterName == "Semua Pekerja") {
          jumlahHarian = jumlahHarian + harian;
          JumlahSimpan = JumlahSimpan + simpan;
          if (rekodGajiFilterDetail
              .map((item) => item.tarikh)
              .contains(tarikh)) {
            int selectIndex = rekodGajiFilterDetail.indexWhere(
              (element) => element.tarikh == tarikh,
            );

            if (selectIndex >= 0) {
              rekodGajiFilter currentfilter = rekodGajiFilterDetail.elementAt(
                selectIndex,
              );
              currentfilter.harian = currentfilter.harian + harian;
              currentfilter.simpan = currentfilter.simpan + simpan;
            }
          } else {
            rekodGajiFilterDetail.add(
              rekodGajiFilter(tarikh, nama, harian, simpan, 0.00),
            );
          }
        }
      }
    }

    for (var index = 0; index < rekod_Pekerja.length; index++) {
      rekodPekerja currentPekerja = rekod_Pekerja.elementAt(index);
      bool cucuk = currentPekerja.cucuk;
      String nama = currentPekerja.username;
      if (!cucuk) {
        if (filterName == nama) {
          List<rekodAmbilGaji> rekod = List<rekodAmbilGaji>.from(
            currentPekerja.rekodAmbil,
          ).toList();
          for (var i = 0; i < rekod.length; i++) {
            rekodAmbilGaji current = rekod.elementAt(i);
            String tarikh0 = current.tarikh;
            jumlahGajiAmbil = jumlahGajiAmbil + current.jumlah;
            if (rekodGajiFilterDetail
                .map((item) => item.tarikh)
                .contains(tarikh0)) {
              int selectIndex = rekodGajiFilterDetail.indexWhere(
                (element) => element.tarikh == tarikh0,
              );

              if (selectIndex >= 0) {
                rekodGajiFilter currentfilter = rekodGajiFilterDetail.elementAt(
                  selectIndex,
                );
                currentfilter.ambil = current.jumlah;
              }
            } else {
              rekodGajiFilterDetail.add(
                rekodGajiFilter(tarikh0, nama, 0.00, 0.00, current.jumlah),
              );
            }
          }
        } else if (filterName == "Semua Pekerja") {
          List<rekodAmbilGaji> rekod = List<rekodAmbilGaji>.from(
            currentPekerja.rekodAmbil,
          ).toList();
          for (var i = 0; i < rekod.length; i++) {
            rekodAmbilGaji current = rekod.elementAt(i);
            String tarikh0 = current.tarikh;
            jumlahGajiAmbil = jumlahGajiAmbil + current.jumlah;
            if (rekodGajiFilterDetail
                .map((item) => item.tarikh)
                .contains(tarikh0)) {
              int selectIndex = rekodGajiFilterDetail.indexWhere(
                (element) => element.tarikh == tarikh0,
              );

              if (selectIndex >= 0) {
                rekodGajiFilter currentfilter = rekodGajiFilterDetail.elementAt(
                  rekodGajiFilterDetail.indexWhere(
                    (element) => element.tarikh == tarikh0,
                  ),
                );
                currentfilter.ambil = current.jumlah;
              }
            } else {
              rekodGajiFilterDetail.add(
                rekodGajiFilter(tarikh0, nama, 0.00, 0.00, current.jumlah),
              );
            }
          }
        }
      }
    }
    rekodGajiFilterDetail.sort((a, b) => a.tarikh.compareTo(b.tarikh));
    return rekodGajiFilterDetail;
  }

  static Future<File> generate(PdfColor color, String nama) async {
    final pdf = pw.Document();

    List<rekodGajiFilter> currentGajiList = reloadData(nama);
    num jumlahHarian = 0.0;
    num jumlahSimpan = 0.0;
    num ambil = 0.0;
    String tarikh = "";
    if (rekod_Gaji.isNotEmpty) {
      if (tarikh == "") {
        rekodGaji currentGaji = rekod_Gaji.elementAt(0);
        String tarikhGaji = currentGaji.tarikh;
        DateTime tempDate1 = DateFormat(
          "dd/MM/yyyy",
        ).parse(tarikhGaji.toString());
        String date = DateFormat('MMMM yyyy').format(tempDate1);
        tarikh = date;
      }
    }
    print("rekod gaji >>> $nama");
    String namaPenuh = "Semua Pekerja";
    String ic = "";
    bool showIC = false;
    if (nama != "Semua Pekerja") {
      rekodPekerja current = rekod_Pekerja.elementAt(
        rekod_Pekerja.indexWhere((element) => element.username == nama),
      );
      namaPenuh = current.namaPenuh;
      ic = current.ic;
      showIC = true;
    }
    for (var index = 0; index < currentGajiList.length; index++) {
      rekodGajiFilter current = currentGajiList.elementAt(index);
      jumlahHarian = jumlahHarian + current.harian;
      jumlahSimpan = jumlahSimpan + current.simpan;
      ambil = ambil + current.ambil;
    }
    num jumlahPendapatan = jumlahSimpan + jumlahHarian;
    final KWSP = (jumlahSimpan * 0.11).round();
    final KWSPMajikan = (jumlahSimpan * 0.13).round();
    num jumlahPotongan = ambil + KWSP;
    num bakiGaji = jumlahSimpan - jumlahPotongan;
    num gajiBersih = jumlahPendapatan - jumlahPotongan;
    print("tarikh >> $tarikh");
    String pdfFile = '$namaPenuh Detail Gaji';
    pdf.addPage(
      pw.MultiPage(
        margin: pw.EdgeInsets.all(10),
        pageFormat: PdfPageFormat.a4,
        orientation: pw.PageOrientation.portrait,
        header: (context) {
          return pw.Column(
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              pw.Row(
                children: [
                  pw.Column(
                    mainAxisSize: pw.MainAxisSize.min,
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Sattay Ussop',
                        style: pw.TextStyle(
                          fontSize: 20.0,
                          fontWeight: pw.FontWeight.bold,
                          color: color,
                          font: fontFamily,
                        ),
                      ),
                      pw.Flexible(
                        child: pw.Text(
                          '(IP0219617-M)',
                          style: pw.TextStyle(
                            fontSize: 14.0,
                            fontWeight: pw.FontWeight.bold,
                            color: color,
                            font: fontFamily,
                          ),
                        ),
                      ),
                    ],
                  ),
                  pw.Spacer(),
                  pw.Column(
                    mainAxisSize: pw.MainAxisSize.min,
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(
                        'Slip Gaji Terperinci',
                        style: pw.TextStyle(color: color, font: fontFamily),
                      ),
                      pw.Text(
                        tarikh,
                        style: pw.TextStyle(color: color, font: fontFamily),
                      ),
                    ],
                  ),
                ],
              ),
              pw.Divider(),
            ],
          );
        },
        build: (context) {
          return <pw.Widget>[
            pw.Column(
              mainAxisSize: pw.MainAxisSize.min,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Nama            : ',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        color: color,
                        font: fontFamily,
                      ),
                    ),
                    pw.Flexible(
                      child: pw.Text(
                        namaPenuh.capitalizeEach(),
                        style: pw.TextStyle(color: color, font: fontFamily),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 1 * PdfPageFormat.mm),
                showIC
                    ? pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Kad Pengenalan  : ',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              color: color,
                              font: fontFamily,
                            ),
                          ),
                          pw.Text(
                            ic,
                            style: pw.TextStyle(color: color, font: fontFamily),
                          ),
                        ],
                      )
                    : pw.SizedBox(height: 1 * PdfPageFormat.mm),
              ],
            ),
            pw.SizedBox(height: 1 * PdfPageFormat.mm),
            pw.Table(
              border: pw.TableBorder.all(),
              columnWidths: <int, pw.TableColumnWidth>{
                0: pw.FlexColumnWidth(),
                1: pw.FlexColumnWidth(),
                2: pw.FlexColumnWidth(),
                3: pw.FlexColumnWidth(),
              },
              children: [
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8.0),
                      child: pw.Text(
                        'Tarikh',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8.0),
                      child: pw.Text(
                        'Harian (RM)',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8.0),
                      child: pw.Text(
                        'Simpan (RM)',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8.0),
                      child: pw.Text(
                        'Ambil (RM)',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            pw.ListView.builder(
              itemCount: currentGajiList.length,
              itemBuilder: (pw.Context context, int index) {
                rekodGajiFilter current = currentGajiList.elementAt(index);
                num harian = current.harian;
                num simpan = current.simpan;
                num ambil = current.ambil;
                return pw.Table(
                  border: pw.TableBorder.all(),
                  columnWidths: <int, pw.TableColumnWidth>{
                    0: pw.FlexColumnWidth(),
                    1: pw.FlexColumnWidth(),
                    2: pw.FlexColumnWidth(),
                    3: pw.FlexColumnWidth(),
                  },
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8.0),
                          child: pw.Text(
                            current.tarikh,
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.normal,
                              color: color,
                              font: fontFamily,
                            ),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8.0),
                          child: pw.Text(
                            '$harian',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.normal,
                              color: color,
                              font: fontFamily,
                            ),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8.0),
                          child: pw.Text(
                            '$simpan',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.normal,
                              color: color,
                              font: fontFamily,
                            ),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8.0),
                          child: pw.Text(
                            '$ambil',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.normal,
                              color: color,
                              font: fontFamily,
                            ),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            pw.Divider(),
            pw.Container(
              alignment: pw.Alignment.centerRight,
              child: pw.Row(
                children: [
                  pw.Spacer(flex: 3),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Row(
                          children: [
                            pw.Expanded(
                              child: pw.Text(
                                'Jumlah Harian (RM)',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  color: color,
                                  font: fontFamily,
                                ),
                              ),
                            ),
                            pw.Text(
                              money(jumlahHarian),
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                color: color,
                                font: fontFamily,
                              ),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 2 * PdfPageFormat.mm),
                        pw.Row(
                          children: [
                            pw.Expanded(
                              child: pw.Text(
                                'Jumlah Simpan (RM)',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  color: color,
                                  font: fontFamily,
                                ),
                              ),
                            ),
                            pw.Text(
                              money(jumlahSimpan),
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                color: color,
                                font: fontFamily,
                              ),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 2 * PdfPageFormat.mm),
                        pw.Row(
                          children: [
                            pw.Expanded(
                              child: pw.Text(
                                'Jumlah Pendapatan (RM)',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  color: color,
                                  font: fontFamily,
                                ),
                              ),
                            ),
                            pw.Text(
                              money(jumlahPendapatan),
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                color: color,
                                font: fontFamily,
                              ),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 2 * PdfPageFormat.mm),
                        ambil > 0.0
                            ? pw.Row(
                                children: [
                                  pw.Expanded(
                                    child: pw.Text(
                                      'Jumlah Ambil (RM)',
                                      style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold,
                                        color: color,
                                        font: fontFamily,
                                      ),
                                    ),
                                  ),
                                  pw.Text(
                                    money(ambil),
                                    style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      color: color,
                                      font: fontFamily,
                                    ),
                                  ),
                                ],
                              )
                            : pw.SizedBox(height: 0),
                        ambil > 0.0
                            ? pw.SizedBox(height: 2 * PdfPageFormat.mm)
                            : pw.SizedBox(height: 0),
                        pw.Row(
                          children: [
                            pw.Expanded(
                              child: pw.Text(
                                'KWSP (RM)',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  color: color,
                                  font: fontFamily,
                                ),
                              ),
                            ),
                            pw.Text(
                              money(KWSP),
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                color: color,
                                font: fontFamily,
                              ),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 2 * PdfPageFormat.mm),
                        pw.Row(
                          children: [
                            pw.Expanded(
                              child: pw.Text(
                                'Jumlah Potongan (RM)',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  color: color,
                                  font: fontFamily,
                                ),
                              ),
                            ),
                            pw.Text(
                              money(jumlahPotongan),
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                color: color,
                                font: fontFamily,
                              ),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 2 * PdfPageFormat.mm),
                        pw.Row(
                          children: [
                            pw.Expanded(
                              child: pw.Text(
                                'KWSP Majikan (RM)',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  color: color,
                                  font: fontFamily,
                                ),
                              ),
                            ),
                            pw.Text(
                              money(KWSPMajikan),
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                color: color,
                                font: fontFamily,
                              ),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 2 * PdfPageFormat.mm),
                        pw.Row(
                          children: [
                            pw.Expanded(
                              child: pw.Text(
                                'Baki Gaji (RM)',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  color: color,
                                  font: fontFamily,
                                ),
                              ),
                            ),
                            pw.Text(
                              money(bakiGaji),
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                color: color,
                                font: fontFamily,
                              ),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 2 * PdfPageFormat.mm),
                        pw.Divider(),
                        pw.Row(
                          children: [
                            pw.Expanded(
                              child: pw.Text(
                                'Gaji Bersih (RM)',
                                style: pw.TextStyle(
                                  fontSize: 17.0,
                                  fontWeight: pw.FontWeight.bold,
                                  color: color,
                                  font: fontFamily,
                                ),
                              ),
                            ),
                            pw.Text(
                              money(gajiBersih),
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                color: color,
                                font: fontFamily,
                              ),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 2 * PdfPageFormat.mm),
                        pw.Container(height: 1, color: PdfColors.grey400),
                        pw.SizedBox(height: 0.5 * PdfPageFormat.mm),
                        pw.Container(height: 1, color: PdfColors.grey400),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ];
        },
      ),
    );
    return FileHandleApi.saveDocument(name: '$pdfFile.pdf', pdf: pdf);
  }
}

class PdfCucukGaji {
  static Future<File> generate(PdfColor color, String nama) async {
    final pdf = pw.Document();
    var filterName = nama;
    List<rekodCucukFilter> currentCucukList = <rekodCucukFilter>[];
    int jumlahSatay = 0;
    num jumlahGaji = 0.00;
    num ambil = 0.00;
    for (var index = 0; index < rekod_Cucuk.length; index++) {
      rekodCucuk cucukList = rekod_Cucuk.elementAt(index);
      String tarikh = cucukList.tarikh;
      List<rekodCucukDetail> stokCucuk = List<rekodCucukDetail>.from(
        cucukList.rekod,
      ).toList();
      for (var k = 0; k < stokCucuk.length; k++) {
        rekodCucukDetail current = stokCucuk.elementAt(k);
        int pekerjaID = current.pekerja_id;
        int jumlah = current.jumlah;
        rekodPekerja gaji =
            rekod_Pekerja[rekod_Pekerja.indexWhere(
              (element) => element.id == pekerjaID,
            )];
        String userName = gaji.username;
        print("filter >> $filterName == $userName | ${filterName == userName}");
        if (filterName == userName) {
          jumlahSatay = jumlahSatay + jumlah;
          num gajiHarian = gaji.gajiHarian;
          num gajiPekerja = jumlah * gajiHarian;
          jumlahGaji = jumlahGaji + gajiPekerja;
          if (!currentCucukList.map((item) => item.tarikh).contains(tarikh)) {
            currentCucukList.add(rekodCucukFilter(tarikh, nama, jumlah));
          } else {
            rekodCucukFilter currentfilter = currentCucukList.elementAt(
              currentCucukList.indexWhere(
                (element) => element.tarikh == tarikh,
              ),
            );
            jumlah = currentfilter.jumlah + jumlah;
            currentfilter.jumlah = jumlah;
          }
        } else if (filterName == "Semua Pekerja") {
          jumlahSatay = jumlahSatay + jumlah;
          num gajiHarian = gaji.gajiHarian;
          num gajiPekerja = jumlah * gajiHarian;
          jumlahGaji = jumlahGaji + gajiPekerja;
          if (!currentCucukList.map((item) => item.tarikh).contains(tarikh)) {
            currentCucukList.add(rekodCucukFilter(tarikh, nama, jumlah));
          } else {
            rekodCucukFilter currentfilter = currentCucukList.elementAt(
              currentCucukList.indexWhere(
                (element) => element.tarikh == tarikh,
              ),
            );
            jumlah = currentfilter.jumlah + jumlah;
            currentfilter.jumlah = jumlah;
          }
        }
      }
    }
    currentCucukList.sort((a, b) => a.tarikh.compareTo(b.tarikh));
    String tarikh = "";
    if (rekod_Cucuk.isNotEmpty) {
      if (tarikh == "") {
        rekodCucuk currentGaji = rekod_Cucuk.elementAt(0);
        String tarikhGaji = currentGaji.tarikh;
        DateTime tempDate1 = DateFormat(
          "dd/MM/yyyy",
        ).parse(tarikhGaji.toString());
        String date = DateFormat('MMMM yyyy').format(tempDate1);
        tarikh = date;
      }
    }
    String namaPenuh = "Semua Pekerja";
    String ic = "";
    bool showIC = false;
    if (nama == "Semua Pekerja") {
      for (var i = 0; i < rekod_Pekerja.length; i++) {
        rekodPekerja gaji = rekod_Pekerja.elementAt(i);
        bool cucuk = gaji.cucuk;
        if (cucuk) {
          List<rekodAmbilGaji> rekod = List<rekodAmbilGaji>.from(
            gaji.rekodAmbil,
          ).toList();
          for (var l = 0; l < rekod.length; l++) {
            rekodAmbilGaji gajiRekod = rekod.elementAt(l);
            ambil = ambil + gajiRekod.jumlah;
          }
        }
      }
    } else {
      rekodPekerja gaji =
          rekod_Pekerja[rekod_Pekerja.indexWhere(
            (element) => element.username == nama,
          )];
      namaPenuh = gaji.namaPenuh;
      ic = gaji.ic;
      showIC = true;
      List<rekodAmbilGaji> rekod = List<rekodAmbilGaji>.from(
        gaji.rekodAmbil,
      ).toList();
      for (var l = 0; l < rekod.length; l++) {
        rekodAmbilGaji gajiRekod = rekod.elementAt(l);
        ambil = ambil + gajiRekod.jumlah;
      }
    }
    num gajiBersih = jumlahGaji - ambil;
    bool showAmbil = false;
    if (ambil > 0) {
      showAmbil = true;
    }
    print("tarikh >> $tarikh");
    String pdfFile = '$namaPenuh Slip Gaji';
    pdf.addPage(
      pw.MultiPage(
        margin: pw.EdgeInsets.all(10),
        pageFormat: PdfPageFormat.a4,
        orientation: pw.PageOrientation.portrait,
        header: (context) {
          return pw.Column(
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              pw.Row(
                children: [
                  pw.Column(
                    mainAxisSize: pw.MainAxisSize.min,
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Sattay Ussop',
                        style: pw.TextStyle(
                          fontSize: 20.0,
                          fontWeight: pw.FontWeight.bold,
                          color: color,
                          font: fontFamily,
                        ),
                      ),
                      pw.Flexible(
                        child: pw.Text(
                          '(IP0219617-M)',
                          style: pw.TextStyle(
                            fontSize: 14.0,
                            fontWeight: pw.FontWeight.bold,
                            color: color,
                            font: fontFamily,
                          ),
                        ),
                      ),
                    ],
                  ),
                  pw.Spacer(),
                  pw.Column(
                    mainAxisSize: pw.MainAxisSize.min,
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(
                        'Slip Gaji',
                        style: pw.TextStyle(color: color, font: fontFamily),
                      ),
                      pw.Text(
                        tarikh,
                        style: pw.TextStyle(color: color, font: fontFamily),
                      ),
                    ],
                  ),
                ],
              ),
              pw.Divider(),
            ],
          );
        },
        build: (context) {
          return <pw.Widget>[
            pw.Column(
              mainAxisSize: pw.MainAxisSize.min,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Nama            : ',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        color: color,
                        font: fontFamily,
                      ),
                    ),
                    pw.Flexible(
                      child: pw.Text(
                        namaPenuh.capitalizeEach(),
                        style: pw.TextStyle(color: color, font: fontFamily),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 1 * PdfPageFormat.mm),
                showIC
                    ? pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Kad Pengenalan  : ',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              color: color,
                              font: fontFamily,
                            ),
                          ),
                          pw.Text(
                            ic,
                            style: pw.TextStyle(color: color, font: fontFamily),
                          ),
                        ],
                      )
                    : pw.SizedBox(height: 1 * PdfPageFormat.mm),
              ],
            ),
            pw.SizedBox(height: 1 * PdfPageFormat.mm),
            pw.Table(
              border: pw.TableBorder.all(),
              columnWidths: <int, pw.TableColumnWidth>{
                0: pw.FlexColumnWidth(),
                1: pw.FlexColumnWidth(),
              },
              children: [
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8.0),
                      child: pw.Text(
                        'Tarikh',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8.0),
                      child: pw.Text(
                        'Jumlah Satay',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            pw.ListView.builder(
              itemCount: currentCucukList.length,
              itemBuilder: (pw.Context context, int index) {
                rekodCucukFilter current = currentCucukList.elementAt(index);
                int jumlah = current.jumlah;
                return pw.Table(
                  border: pw.TableBorder.all(),
                  columnWidths: <int, pw.TableColumnWidth>{
                    0: pw.FlexColumnWidth(),
                    1: pw.FlexColumnWidth(),
                  },
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8.0),
                          child: pw.Text(
                            current.tarikh,
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.normal,
                              color: color,
                              font: fontFamily,
                            ),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8.0),
                          child: pw.Text(
                            '$jumlah',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.normal,
                              color: color,
                              font: fontFamily,
                            ),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            pw.Divider(),
            pw.Container(
              alignment: pw.Alignment.centerRight,
              child: pw.Row(
                children: [
                  pw.Spacer(flex: 3),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Row(
                          children: [
                            pw.Expanded(
                              child: pw.Text(
                                'Jumlah Satay',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  color: color,
                                  font: fontFamily,
                                ),
                              ),
                            ),
                            pw.Text(
                              '$jumlahSatay',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                color: color,
                                font: fontFamily,
                              ),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 2 * PdfPageFormat.mm),
                        pw.Row(
                          children: [
                            pw.Expanded(
                              child: pw.Text(
                                'Pendapatan (RM)',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  color: color,
                                  font: fontFamily,
                                ),
                              ),
                            ),
                            pw.Text(
                              money(jumlahGaji),
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                color: color,
                                font: fontFamily,
                              ),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 2 * PdfPageFormat.mm),
                        showAmbil
                            ? pw.Row(
                                children: [
                                  pw.Expanded(
                                    child: pw.Text(
                                      'Gaji Ambil (RM)',
                                      style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold,
                                        color: color,
                                        font: fontFamily,
                                      ),
                                    ),
                                  ),
                                  pw.Text(
                                    money(ambil),
                                    style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      color: color,
                                      font: fontFamily,
                                    ),
                                  ),
                                ],
                              )
                            : pw.SizedBox(height: 0),
                        pw.SizedBox(height: 2 * PdfPageFormat.mm),
                        pw.Divider(),
                        pw.Row(
                          children: [
                            pw.Expanded(
                              child: pw.Text(
                                'Gaji Bersih (RM)',
                                style: pw.TextStyle(
                                  fontSize: 17.0,
                                  fontWeight: pw.FontWeight.bold,
                                  color: color,
                                  font: fontFamily,
                                ),
                              ),
                            ),
                            pw.Text(
                              money(gajiBersih),
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                color: color,
                                font: fontFamily,
                              ),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 2 * PdfPageFormat.mm),
                        pw.Container(height: 1, color: PdfColors.grey400),
                        pw.SizedBox(height: 0.5 * PdfPageFormat.mm),
                        pw.Container(height: 1, color: PdfColors.grey400),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ];
        },
      ),
    );
    return FileHandleApi.saveDocument(name: '$pdfFile.pdf', pdf: pdf);
  }
}

class PdfPembekalResit {
  static Future<File> generate(
    PdfColor color,
    String nama,
    String tarikhRekod,
  ) async {
    final pdf = pw.Document();
    rekodPembekalList pembekalList = rekod_Pembekal.elementAt(
      rekod_Pembekal.indexWhere((element) => element.namaPembekal == nama),
    );
    List<rekodPembekalDetail> rekodPembekal = List<rekodPembekalDetail>.from(
      pembekalList.rekod,
    ).toList();
    rekodPembekalDetail current = rekodPembekal.elementAt(
      rekodPembekal.indexWhere((element) => element.tarikh == tarikhRekod),
    );
    Map<String, dynamic> rekodBarang = current.rekodBarang;
    String tarikh = "${current.hari}, ${current.tarikh}";
    print("rekod pembekal >>> $nama >> ${rekodBarang.length}");
    String pdfFile = '$nama Resit';
    pdf.addPage(
      pw.MultiPage(
        margin: pw.EdgeInsets.all(10),
        pageFormat: PdfPageFormat.a4,
        orientation: pw.PageOrientation.portrait,
        header: (context) {
          return pw.Column(
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              pw.Row(
                children: [
                  pw.Column(
                    mainAxisSize: pw.MainAxisSize.min,
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Sattay Ussop',
                        style: pw.TextStyle(
                          fontSize: 20.0,
                          fontWeight: pw.FontWeight.bold,
                          color: color,
                          font: fontFamily,
                        ),
                      ),
                      pw.Flexible(
                        child: pw.Text(
                          '(IP0219617-M)',
                          style: pw.TextStyle(
                            fontSize: 14.0,
                            fontWeight: pw.FontWeight.bold,
                            color: color,
                            font: fontFamily,
                          ),
                        ),
                      ),
                    ],
                  ),
                  pw.Spacer(),
                  pw.Column(
                    mainAxisSize: pw.MainAxisSize.min,
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(
                        'Resit Pembekal',
                        style: pw.TextStyle(color: color, font: fontFamily),
                      ),
                    ],
                  ),
                ],
              ),
              pw.Divider(),
            ],
          );
        },
        build: (context) {
          return <pw.Widget>[
            pw.Column(
              mainAxisSize: pw.MainAxisSize.min,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Nama    : ',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        color: color,
                        font: fontFamily,
                      ),
                    ),
                    pw.Flexible(
                      child: pw.Text(
                        nama.capitalizeEach(),
                        style: pw.TextStyle(color: color, font: fontFamily),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 1 * PdfPageFormat.mm),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Tarikh  : ',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        color: color,
                        font: fontFamily,
                      ),
                    ),
                    pw.Flexible(
                      child: pw.Text(
                        tarikh.capitalizeEach(),
                        style: pw.TextStyle(color: color, font: fontFamily),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 1 * PdfPageFormat.mm),
            pw.Table(
              border: pw.TableBorder.all(),
              columnWidths: <int, pw.TableColumnWidth>{
                0: pw.FlexColumnWidth(),
                1: pw.FlexColumnWidth(),
              },
              children: [
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8.0),
                      child: pw.Text(
                        'Barang',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8.0),
                      child: pw.Text(
                        'Kuantiti',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            pw.ListView.builder(
              itemCount: rekodBarang.length,
              itemBuilder: (pw.Context context, int index) {
                String nama = rekodBarang.keys.elementAt(index);
                String barang = nama.capitalizeEach();
                String kuantiti = rekodBarang[nama];
                var unit = senarai_Barang
                    .elementAt(senarai_Barang.indexWhere((e) => e.nama == nama))
                    .unit;
                print("list menu >>> $barang");
                return pw.Table(
                  border: pw.TableBorder.all(),
                  columnWidths: <int, pw.TableColumnWidth>{
                    0: pw.FlexColumnWidth(),
                    1: pw.FlexColumnWidth(),
                  },
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8.0),
                          child: pw.Text(
                            barang,
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.normal,
                              color: color,
                              font: fontFamily,
                            ),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8.0),
                          child: pw.Text(
                            "$kuantiti $unit",
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.normal,
                              color: color,
                              font: fontFamily,
                            ),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ];
        },
      ),
    );
    print("successfully save pdf $pdfFile");
    return FileHandleApi.saveDocument(name: '$pdfFile.pdf', pdf: pdf);
  }
}

class PdfBayaranPembekalResit {
  static Future<File> generate(
    PdfColor color,
    String nama,
    String tarikhRekod,
  ) async {
    final pdf = pw.Document();
    rekodPembekalList pembekalList = rekod_Pembekal.elementAt(
      rekod_Pembekal.indexWhere((element) => element.namaPembekal == nama),
    );
    List<rekodPembekalDetail> rekodPembekal = List<rekodPembekalDetail>.from(
      pembekalList.rekod,
    ).toList();
    // rekodPembekalDetail current = rekodPembekal.elementAt(
    //   rekodPembekal.indexWhere((element) => element.tarikh == tarikhRekod),
    // );
    List<rekodBayaranPembekal> rekodBayaran = List<rekodBayaranPembekal>.from(
      pembekalList.rekodBayaran,
    ).toList();
    rekodBayaran.sort((a, b) => a.tarikh.compareTo(b.tarikh));

    num jumlahKeseluruhan = 0.0;
    num jumlahBayaran = 0.0;
    for (var index = 0; index < rekodBayaran.length; index++) {
      rekodBayaranPembekal current = rekodBayaran.elementAt(index);
      jumlahBayaran = jumlahBayaran + current.bayaran;
    }
    rekodBayaran.sort((a, b) => a.tarikh.compareTo(b.tarikh));
    for (var index = 0; index < rekodPembekal.length; index++) {
      var current = rekodPembekal[index];
      var jumlahBayaran = current.jumlah;
      jumlahKeseluruhan += jumlahBayaran;
    }
    // String tarikh = "${current.hari}, ${current.tarikh}";
    print("rekod pembekal >>> $nama >> ${rekodBayaran.length}");
    String pdfFile = 'Rekod Bayaran Pembekal $nama Resit';
    pdf.addPage(
      pw.MultiPage(
        margin: pw.EdgeInsets.all(10),
        pageFormat: PdfPageFormat.a4,
        orientation: pw.PageOrientation.portrait,
        header: (context) {
          return pw.Column(
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              pw.Row(
                children: [
                  pw.Column(
                    mainAxisSize: pw.MainAxisSize.min,
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Sattay Ussop',
                        style: pw.TextStyle(
                          fontSize: 20.0,
                          fontWeight: pw.FontWeight.bold,
                          color: color,
                          font: fontFamily,
                        ),
                      ),
                      pw.Flexible(
                        child: pw.Text(
                          '(IP0219617-M)',
                          style: pw.TextStyle(
                            fontSize: 14.0,
                            fontWeight: pw.FontWeight.bold,
                            color: color,
                            font: fontFamily,
                          ),
                        ),
                      ),
                    ],
                  ),
                  pw.Spacer(),
                  pw.Column(
                    mainAxisSize: pw.MainAxisSize.min,
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(
                        'Resit Pembekal',
                        style: pw.TextStyle(color: color, font: fontFamily),
                      ),
                    ],
                  ),
                ],
              ),
              pw.Divider(),
            ],
          );
        },
        build: (context) {
          return <pw.Widget>[
            pw.Column(
              mainAxisSize: pw.MainAxisSize.min,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Nama    : ',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        color: color,
                        font: fontFamily,
                      ),
                    ),
                    pw.Flexible(
                      child: pw.Text(
                        nama.capitalizeEach(),
                        style: pw.TextStyle(color: color, font: fontFamily),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 1 * PdfPageFormat.mm),
                // pw.Row(
                //   mainAxisAlignment: pw.MainAxisAlignment.start,
                //   children: [
                //     pw.Text(
                //       'Tarikh  : ',
                //       style: pw.TextStyle(
                //         fontWeight: pw.FontWeight.bold,
                //         color: color,
                //         font: fontFamily,
                //       ),
                //     ),
                //     pw.Flexible(
                //       child: pw.Text(
                //         tarikh.capitalizeEach(),
                //         style: pw.TextStyle(color: color, font: fontFamily),
                //       ),
                //     ),
                //   ],
                // ),
              ],
            ),
            pw.SizedBox(height: 1 * PdfPageFormat.mm),
            pw.Table(
              border: pw.TableBorder.all(),
              columnWidths: <int, pw.TableColumnWidth>{
                0: pw.FlexColumnWidth(),
                1: pw.FlexColumnWidth(),
              },
              children: [
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8.0),
                      child: pw.Text(
                        'Tarikh',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8.0),
                      child: pw.Text(
                        'Bayaran (RM)',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            pw.ListView.builder(
              itemCount: rekodBayaran.length,
              itemBuilder: (pw.Context context, int index) {
                rekodBayaranPembekal current = rekodBayaran.elementAt(index);
                String tarikhBayar = current.tarikh.capitalizeEach();
                String jumlah = money(current.bayaran);
                return pw.Table(
                  border: pw.TableBorder.all(),
                  columnWidths: <int, pw.TableColumnWidth>{
                    0: pw.FlexColumnWidth(),
                    1: pw.FlexColumnWidth(),
                  },
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8.0),
                          child: pw.Text(
                            tarikhBayar,
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.normal,
                              color: color,
                              font: fontFamily,
                            ),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8.0),
                          child: pw.Text(
                            jumlah,
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.normal,
                              color: color,
                              font: fontFamily,
                            ),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            pw.Divider(),
            pw.Container(
              alignment: pw.Alignment.centerRight,
              child: pw.Row(
                children: [
                  pw.Spacer(flex: 3),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Row(
                          children: [
                            pw.Expanded(
                              child: pw.Text(
                                'Jumlah Keseluruhan (RM)',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  color: color,
                                  font: fontFamily,
                                ),
                              ),
                            ),
                            pw.Text(
                              money(jumlahKeseluruhan),
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                color: color,
                                font: fontFamily,
                              ),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 2 * PdfPageFormat.mm),
                        pw.Row(
                          children: [
                            pw.Expanded(
                              child: pw.Text(
                                'Jumlah Sudah Bayar (RM)',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  color: color,
                                  font: fontFamily,
                                ),
                              ),
                            ),
                            pw.Text(
                              money(jumlahBayaran),
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                color: color,
                                font: fontFamily,
                              ),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 2 * PdfPageFormat.mm),
                        pw.Divider(),
                        pw.Row(
                          children: [
                            pw.Expanded(
                              child: pw.Text(
                                'Baki Bayaran (RM)',
                                style: pw.TextStyle(
                                  fontSize: 17.0,
                                  fontWeight: pw.FontWeight.bold,
                                  color: color,
                                  font: fontFamily,
                                ),
                              ),
                            ),
                            pw.Text(
                              money(jumlahKeseluruhan - jumlahBayaran),
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                color: color,
                                font: fontFamily,
                              ),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 2 * PdfPageFormat.mm),
                        pw.Container(height: 1, color: PdfColors.grey400),
                        pw.SizedBox(height: 0.5 * PdfPageFormat.mm),
                        pw.Container(height: 1, color: PdfColors.grey400),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ];
        },
      ),
    );
    print("successfully save pdf $pdfFile");
    return FileHandleApi.saveDocument(name: '$pdfFile.pdf', pdf: pdf);
  }
}

class PdfBayaranCawanganResit {
  static Future<File> generate(
    PdfColor color,
    String nama,
    String tarikhRekod,
  ) async {
    final pdf = pw.Document();
    rekodCawangan cawanganList = rekod_Cawangan.elementAt(
      rekod_Cawangan.indexWhere((element) => element.nama == nama),
    );
    List<rekodCawanganDetail> _rekodCawangan = List<rekodCawanganDetail>.from(
      cawanganList.rekod,
    ).toList();
    // rekodCawanganDetail current = _rekodCawangan.elementAt(
    //   _rekodCawangan.indexWhere((element) => element.tarikh == tarikhRekod),
    // );
    List<rekodBayaranCawangan> rekodBayaran = List<rekodBayaranCawangan>.from(
      cawanganList.rekodBayaran,
    ).toList();
    num jumlahKeseluruhan = 0.0;
    num jumlahBayaran = 0.0;
    for (var index = 0; index < rekodBayaran.length; index++) {
      rekodBayaranCawangan current = rekodBayaran.elementAt(index);
      jumlahBayaran = jumlahBayaran + current.bayaran;
    }
    rekodBayaran.sort((a, b) => a.tarikh.compareTo(b.tarikh));
    for (var index = 0; index < _rekodCawangan.length; index++) {
      var current = _rekodCawangan[index];
      var jumlahBayaran = current.jumlahJualan;
      jumlahKeseluruhan += jumlahBayaran;
    }
    print("rekod cawangan >>> $nama >> ${rekodBayaran.length}");
    String pdfFile = 'Rekod Cawangan Bayaran $nama';
    pdf.addPage(
      pw.MultiPage(
        margin: pw.EdgeInsets.all(10),
        pageFormat: PdfPageFormat.a4,
        orientation: pw.PageOrientation.portrait,
        header: (context) {
          return pw.Column(
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              pw.Row(
                children: [
                  pw.Column(
                    mainAxisSize: pw.MainAxisSize.min,
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Sattay Ussop',
                        style: pw.TextStyle(
                          fontSize: 20.0,
                          fontWeight: pw.FontWeight.bold,
                          color: color,
                          font: fontFamily,
                        ),
                      ),
                      pw.Flexible(
                        child: pw.Text(
                          '(IP0219617-M)',
                          style: pw.TextStyle(
                            fontSize: 14.0,
                            fontWeight: pw.FontWeight.bold,
                            color: color,
                            font: fontFamily,
                          ),
                        ),
                      ),
                    ],
                  ),
                  pw.Spacer(),
                  pw.Column(
                    mainAxisSize: pw.MainAxisSize.min,
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(
                        'Resit Cawangan',
                        style: pw.TextStyle(color: color, font: fontFamily),
                      ),
                    ],
                  ),
                ],
              ),
              pw.Divider(),
            ],
          );
        },
        build: (context) {
          return <pw.Widget>[
            pw.Column(
              mainAxisSize: pw.MainAxisSize.min,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Nama    : ',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        color: color,
                        font: fontFamily,
                      ),
                    ),
                    pw.Flexible(
                      child: pw.Text(
                        nama.capitalizeEach(),
                        style: pw.TextStyle(color: color, font: fontFamily),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 1 * PdfPageFormat.mm),
              ],
            ),
            pw.SizedBox(height: 1 * PdfPageFormat.mm),
            pw.Table(
              border: pw.TableBorder.all(),
              columnWidths: <int, pw.TableColumnWidth>{
                0: pw.FlexColumnWidth(),
                1: pw.FlexColumnWidth(),
              },
              children: [
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8.0),
                      child: pw.Text(
                        'Tarikh',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8.0),
                      child: pw.Text(
                        'Bayaran (RM)',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            pw.ListView.builder(
              itemCount: rekodBayaran.length,
              itemBuilder: (pw.Context context, int index) {
                rekodBayaranCawangan current = rekodBayaran.elementAt(index);
                String tarikhBayar = current.tarikh.capitalizeEach();
                String jumlah = money(current.bayaran);
                return pw.Table(
                  border: pw.TableBorder.all(),
                  columnWidths: <int, pw.TableColumnWidth>{
                    0: pw.FlexColumnWidth(),
                    1: pw.FlexColumnWidth(),
                  },
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8.0),
                          child: pw.Text(
                            tarikhBayar,
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.normal,
                              color: color,
                              font: fontFamily,
                            ),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8.0),
                          child: pw.Text(
                            jumlah,
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.normal,
                              color: color,
                              font: fontFamily,
                            ),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            pw.Divider(),
            pw.Container(
              alignment: pw.Alignment.centerRight,
              child: pw.Row(
                children: [
                  pw.Spacer(flex: 3),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Row(
                          children: [
                            pw.Expanded(
                              child: pw.Text(
                                'Jumlah Keseluruhan (RM)',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  color: color,
                                  font: fontFamily,
                                ),
                              ),
                            ),
                            pw.Text(
                              money(jumlahKeseluruhan),
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                color: color,
                                font: fontFamily,
                              ),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 2 * PdfPageFormat.mm),
                        pw.Row(
                          children: [
                            pw.Expanded(
                              child: pw.Text(
                                'Jumlah Sudah Bayar (RM)',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  color: color,
                                  font: fontFamily,
                                ),
                              ),
                            ),
                            pw.Text(
                              money(jumlahBayaran),
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                color: color,
                                font: fontFamily,
                              ),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 2 * PdfPageFormat.mm),
                        pw.Divider(),
                        pw.Row(
                          children: [
                            pw.Expanded(
                              child: pw.Text(
                                'Baki Bayaran (RM)',
                                style: pw.TextStyle(
                                  fontSize: 17.0,
                                  fontWeight: pw.FontWeight.bold,
                                  color: color,
                                  font: fontFamily,
                                ),
                              ),
                            ),
                            pw.Text(
                              money(jumlahKeseluruhan - jumlahBayaran),
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                color: color,
                                font: fontFamily,
                              ),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 2 * PdfPageFormat.mm),
                        pw.Container(height: 1, color: PdfColors.grey400),
                        pw.SizedBox(height: 0.5 * PdfPageFormat.mm),
                        pw.Container(height: 1, color: PdfColors.grey400),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ];
        },
      ),
    );
    print("successfully save pdf $pdfFile");
    return FileHandleApi.saveDocument(name: '$pdfFile.pdf', pdf: pdf);
  }
}
