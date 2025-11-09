import 'package:flutter/material.dart';
import 'package:inventora_app/src/controllers/registrarproducto_controller.dart';
import 'package:inventora_app/src/models/registrarproducto_model.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({Key? key}) : super(key: key);

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final _searchController = TextEditingController();
  String selectedCategory = 'Todas las categorías';
  String selectedStatus = 'Todos los estados';
  int _selectedIndex = 1;

  final ProductController _productController = ProductController();
  List<Product> filteredProducts = [];

  // Controllers del diálogo
  final TextEditingController nameController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController stockController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController providerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredProducts = _productController.getProducts();
    _searchController.addListener(_filterProducts);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterProducts() {
    setState(() {
      filteredProducts = _productController.filterProducts(
        _searchController.text,
        selectedCategory,
        selectedStatus,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildHeader(),
            const SizedBox(height: 20),
            _buildSearchBar(),
            const SizedBox(height: 16),
            _buildFilters(),
            const SizedBox(height: 20),
            _buildProductsList(),
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Gestión de Inventario',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0A0E27),
            ),
          ),
          ElevatedButton.icon(
            onPressed: _showAddProductDialog,
            icon: const Icon(Icons.add),
            label: const Text('Agregar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0A0E27),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar productos...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          hintStyle: const TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildFilterDropdown(
              'Todas las categorías',
              ['Todas las categorías', 'Electrónicos', 'Ropa', 'Hogar', 'Deportes'],
              (value) {
                setState(() {
                  selectedCategory = value;
                  _filterProducts();
                });
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildFilterDropdown(
              'Todos los estados',
              ['Todos los estados', 'Óptimo', 'Medio', 'Bajo'],
              (value) {
                setState(() {
                  selectedStatus = value;
                  _filterProducts();
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: _showAddProductDialog,
      backgroundColor: const Color(0xFF0A0E27),
      icon: const Icon(Icons.add),
      label: const Text('Agregar Producto'),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0A0E27),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, 'Inicio', 0),
              _buildNavItem(Icons.inventory_2_outlined, 'Inventario', 1),
              _buildNavItem(Icons.trending_up, 'Predicción', 2),
              _buildNavItem(Icons.notifications_outlined, 'Alertas', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: isSelected ? Colors.black : Colors.white, size: 24),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white70,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsList() {
    if (filteredProducts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text('No hay productos',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(children: filteredProducts.map(_buildProductCard).toList()),
    );
  }

  Widget _buildProductCard(Product product) {
    // ✅ Recalcular SIEMPRE según el stock actual (clave para que se pinte bien)
    final ss = Product.getStockStatus(product.stock);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(product.name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0A0E27))),
                const SizedBox(height: 8),
                Row(children: [
                  Text('Categoría: ${product.category}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const Spacer(),
                  Text('Stock: ${product.stock}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ]),
                const SizedBox(height: 12),
                Text('Precio: ${product.price}', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                const SizedBox(height: 8),
                Row(children: [
                  Text('Proveedor: ${product.provider}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const Spacer(),
                  Text('Ubicación: ${product.location}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ]),
              ]),
            ),
            const SizedBox(width: 8),
            Column(children: [
              IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => _showEditProductDialog(product)),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444)),
                onPressed: () => _deleteProduct(product),
              ),
            ]),
          ]),

          // ✅ Badge de estado pintado con el cálculo dinámico (NO usa product.status/product.statusColor)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: ss.color, // 🔥 color según stock
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(children: [
                  const Icon(Icons.warning_amber_outlined, size: 14, color: Colors.white),
                  const SizedBox(width: 6),
                  Text(ss.text, // 🔥 texto según stock: Bajo / Medio / Óptimo
                      style: const TextStyle(color: Colors.white, fontSize: 12)),
                ]),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(
    String value,
    List<String> items,
    Function(String) onChanged,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        underline: const SizedBox(),
        items: items.map((String item) {
          return DropdownMenuItem<String>(value: item, child: Text(item));
        }).toList(),
        onChanged: (String? newValue) {
          if (newValue != null) onChanged(newValue);
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF0A0E27),
      elevation: 0,
      title: Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.inventory_2_outlined, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Inventario Pro', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Hola, Administrador', style: TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ]),
      actions: [IconButton(icon: const Icon(Icons.person_outline, color: Colors.white), onPressed: () {})],
    );
  }

  void _showAddProductDialog() => _showProductDialog(null);
  void _showEditProductDialog(Product product) => _showProductDialog(product);

  void _showProductDialog(Product? product) {
    nameController.text = product?.name ?? '';
    categoryController.text = product?.category ?? '';
    priceController.text = product?.price ?? 'S/ ';
    stockController.text = product?.stock.toString() ?? '';
    locationController.text = product?.location ?? '';
    providerController.text = product?.provider ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(product == null ? 'Agregar Producto' : 'Editar Producto'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nombre del Producto')),
              TextField(controller: categoryController, decoration: const InputDecoration(labelText: 'Categoría')),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Precio', prefixText: 'S/.',),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: stockController,
                decoration: const InputDecoration(labelText: 'Stock'),
                keyboardType: TextInputType.number,
              ),
              TextField(controller: locationController, decoration: const InputDecoration(labelText: 'Ubicación')),
              TextField(controller: providerController, decoration: const InputDecoration(labelText: 'Proveedor')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              final parsedStock = int.tryParse(
                stockController.text.replaceAll(RegExp(r'[^0-9]'), '')
              ) ?? 0;

              final ss = Product.getStockStatus(parsedStock);

              if (product == null) {
                final newProduct = Product(
                  name: nameController.text.trim(),
                  category: categoryController.text.trim(),
                  price: priceController.text.trim(),
                  stock: parsedStock,
                  location: locationController.text.trim(),
                  provider: providerController.text.trim(),
                  date: DateTime.now().toString().split(' ')[0],
                  status: ss.text,
                  statusColor: ss.color,
                );
                setState(() {
                  _productController.addProduct(newProduct);
                  _filterProducts();
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Agregado: estado "${ss.text}"')),
                );
              } else {
                final editedProduct = Product(
                  name: nameController.text.trim(),
                  category: categoryController.text.trim(),
                  price: priceController.text.trim(),
                  stock: parsedStock,
                  location: locationController.text.trim(),
                  provider: providerController.text.trim(),
                  date: product.date,
                  status: ss.text,
                  statusColor: ss.color,
                );
                setState(() {
                  _productController.editProduct(
                    filteredProducts.indexOf(product),
                    editedProduct,
                  );
                  _filterProducts();
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Actualizado: estado "${ss.text}"')),
                );
              }
              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _deleteProduct(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Producto'),
        content: Text('¿Estás seguro de que deseas eliminar "${product.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            onPressed: () {
              setState(() {
                _productController.deleteProduct(filteredProducts.indexOf(product));
                _filterProducts();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Producto eliminado')),
              );
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
