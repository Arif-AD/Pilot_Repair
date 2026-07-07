import 'package:postgres/postgres.dart';
import 'package:pilot_repair_backend/database.dart';
import 'package:pilot_repair_backend/models/lcd_order.dart';

class LcdOrderService {
  final Database _db = Database();

  Future<List<LcdOrder>> getAll() async {
    await _db.connect();
    final List<List<dynamic>> results = await _db.connection.query(
        '''
      SELECT 
        id::text, brand, series, damage_type, lcd_quality, price::float8, 
        status, technician_id, created_at, updated_at 
      FROM lcd_orders
      ORDER BY created_at DESC
      '''
    );
    return results.map((row) => LcdOrder(
      id: int.parse(row[0] as String),
      brand: row[1] as String,
      series: row[2] as String,
      damageType: row[3] as String,
      lcdQuality: row[4] as String,
      price: row[5] as double,
      status: row[6] as String,
      technicianId: row[7] as String?,
      createdAt: row[8] as DateTime?,
      updatedAt: row[9] as DateTime?,
    ),).toList();
  }

  Future<LcdOrder?> getById(int id) async {
    await _db.connect();
    final List<List<dynamic>> results = await _db.connection.query(
      '''
      SELECT 
        id::text, brand, series, damage_type, lcd_quality, price::float8, 
        status, technician_id, created_at, updated_at 
      FROM lcd_orders 
      WHERE id = @id
      ''',
      substitutionValues: {'id': id},
    );
    if (results.isEmpty) return null;

    final row = results.first;
    return LcdOrder(
      id: int.parse(row[0] as String),
      brand: row[1] as String,
      series: row[2] as String,
      damageType: row[3] as String,
      lcdQuality: row[4] as String,
      price: row[5] as double,
      status: row[6] as String,
      technicianId: row[7] as String?,
      createdAt: row[8] as DateTime?,
      updatedAt: row[9] as DateTime?,
    );
  }

  Future<void> insert(LcdOrder order) async {
    await _db.connect();
    await _db.connection.query(
      '''
      INSERT INTO lcd_orders 
        (brand, series, damage_type, lcd_quality, price, status, technician_id)
      VALUES 
        (@brand, @series, @damageType, @lcdQuality, @price, @status, @technicianId)
      ''',
      substitutionValues: {
        'brand': order.brand,
        'series': order.series,
        'damageType': order.damageType,
        'lcdQuality': order.lcdQuality,
        'price': order.price,
        'status': order.status,
        'technicianId': order.technicianId,
      },
    );
  }

  Future<void> update(int id, LcdOrder order) async {
    await _db.connect();
    await _db.connection.query(
      '''
      UPDATE lcd_orders 
      SET 
        brand = @brand,
        series = @series,
        damage_type = @damageType,
        lcd_quality = @lcdQuality,
        price = @price,
        status = @status,
        technician_id = @technicianId,
        updated_at = CURRENT_TIMESTAMP
      WHERE id = @id
      ''',
      substitutionValues: {
        'id': id,
        'brand': order.brand,
        'series': order.series,
        'damageType': order.damageType,
        'lcdQuality': order.lcdQuality,
        'price': order.price,
        'status': order.status,
        'technicianId': order.technicianId,
      },
    );
  }

  Future<void> delete(int id) async {
    await _db.connect();
    await _db.connection.query(
      'DELETE FROM lcd_orders WHERE id = @id',
      substitutionValues: {'id': id},
    );
  }
}
