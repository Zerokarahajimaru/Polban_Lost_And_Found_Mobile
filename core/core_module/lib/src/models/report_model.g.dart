// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReportModelAdapter extends TypeAdapter<ReportModel> {
  @override
  final int typeId = 0;

  @override
  ReportModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReportModel(
      id: fields[0] as String?,
      userId: fields[1] as String,
      namaBarang: fields[2] as String,
      kategoriBarang: fields[3] as String,
      statusPostingan: fields[4] as String,
      deskripsiBarang: fields[5] as String,
      lokasiKehilangan: fields[6] as String,
      warnaBarang: fields[7] as String,
      kontak: fields[8] as String,
      reportCount: fields[9] as int,
      lastActivityAt: fields[10] as DateTime,
      createdAt: fields[11] as DateTime,
      updatedAt: fields[12] as DateTime,
      isSynced: fields[13] as bool,
      images: (fields[14] as List).cast<String>(),
      bounty: fields[15] as BountyModel?,
    );
  }

  @override
  void write(BinaryWriter writer, ReportModel obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.namaBarang)
      ..writeByte(3)
      ..write(obj.kategoriBarang)
      ..writeByte(4)
      ..write(obj.statusPostingan)
      ..writeByte(5)
      ..write(obj.deskripsiBarang)
      ..writeByte(6)
      ..write(obj.lokasiKehilangan)
      ..writeByte(7)
      ..write(obj.warnaBarang)
      ..writeByte(8)
      ..write(obj.kontak)
      ..writeByte(9)
      ..write(obj.reportCount)
      ..writeByte(10)
      ..write(obj.lastActivityAt)
      ..writeByte(11)
      ..write(obj.createdAt)
      ..writeByte(12)
      ..write(obj.updatedAt)
      ..writeByte(13)
      ..write(obj.isSynced)
      ..writeByte(14)
      ..write(obj.images)
      ..writeByte(15)
      ..write(obj.bounty);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BountyModelAdapter extends TypeAdapter<BountyModel> {
  @override
  final int typeId = 1;

  @override
  BountyModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BountyModel(
      amount: fields[0] as double,
      currency: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, BountyModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.amount)
      ..writeByte(1)
      ..write(obj.currency);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BountyModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
