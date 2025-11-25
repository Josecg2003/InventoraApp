import 'package:flutter/material.dart';
import 'package:inventora_app/src/views/home.dart';
import 'package:inventora_app/src/views/alertas_notif.dart';
import 'package:inventora_app/src/views/login.dart';
import 'package:inventora_app/src/views/prediccion.dart';
import 'package:provider/provider.dart';
import 'package:inventora_app/src/controllers/product_controller.dart';
import 'package:inventora_app/src/models/product_model.dart'; // Importamos el modelo correcto

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
    void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que deseas salir?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Cierra el diálogo
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              // 1. Cierra el diálogo
              Navigator.pop(context);
              
              // 2. Navega al Login y BORRA el historial anterior
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()), 
                (Route<dynamic> route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444), // Rojo para indicar salida
              foregroundColor: Colors.white,
            ),
            child: const Text('Salir'),
          ),
        ],
      ),
    );
  }
  // ⛔ 2. ELIMINAMOS LA LISTA DE PRODUCTOS DE EJEMPLO
  // List<Product> products = [ ... ];

  // ✅ Esta lista ahora guardará los productos FILTRADOS
  List<Product> filteredProducts = [];
  
  // ✅ Guardamos la lista completa de la API aquí
  List<Product> allProductsFromApi = [];

  @override
  void initState() {
    super.initState();
    // ✅ Agregamos el listener. _filterProducts se llamará cuando el usuario escriba
    _searchController.addListener(_filterProducts);

    // ✅ Obtenemos los productos del controlador tan pronto la vista se construye
    // Usamos 'addPostFrameCallback' para asegurarnos de que el 'context' esté listo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Usamos 'read' porque solo queremos obtener los datos una vez
      final productController = context.read<ProductController>();
      
      // Si los productos ya se cargaron en el Home, los usamos
      if (productController.products.isNotEmpty) {
        allProductsFromApi = productController.products;
        _filterProducts(); // Aplicamos filtros iniciales
      } else {
        // Si no, forzamos una recarga (por si el usuario entró directo aquí)
        productController.refreshProducts().then((_) {
          allProductsFromApi = productController.products;
          _filterProducts();
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ✅ 3. LÓGICA DE FILTRO ACTUALIZADA
  void _filterProducts() {
    // Obtenemos los filtros actuales
    final String query = _searchController.text.toLowerCase();
    
    // Filtramos desde la lista COMPLETA de la API
    final List<Product> tempFilteredList = allProductsFromApi.where((product) {
      
      final matchesSearch = product.name.toLowerCase().contains(query) ||
          (product.category?.toLowerCase() ?? '').contains(query);

      final matchesCategory = selectedCategory == 'Todas las categorías' ||
          product.category == selectedCategory;

      final matchesStatus = selectedStatus == 'Todos los estados' ||
          product.status == selectedStatus;

      return matchesSearch && matchesCategory && matchesStatus;
    }).toList();

    // Actualizamos el estado para redibujar la UI
    setState(() {
      filteredProducts = tempFilteredList;
    });
  }

  @override
  Widget build(BuildContext context) {
    // ✅ 4. USAMOS CONSUMER PARA REACCIONAR A CARGA Y ERRORES
    return Consumer<ProductController>(
      builder: (context, controller, child) {
        
        // ✅✅✅ INICIO DE LA SOLUCIÓN (PROBLEMA 2) ✅✅✅
        //
        // Sincroniza la lista local con la del controlador CADA VEZ que el
        // controlador notifica un cambio (ej. después de agregar/editar).
        allProductsFromApi = controller.products;

        // Vuelve a calcular la lista filtrada INMEDIATAMENTE.
        final String query = _searchController.text.toLowerCase();
        filteredProducts = allProductsFromApi.where((product) {
          final matchesSearch = product.name.toLowerCase().contains(query) ||
              (product.category?.toLowerCase() ?? '').contains(query);

          final matchesCategory = selectedCategory == 'Todas las categorías' ||
              product.category == selectedCategory;

          final matchesStatus = selectedStatus == 'Todos los estados' ||
              product.status == selectedStatus;
          return matchesSearch && matchesCategory && matchesStatus;
        }).toList();
        //
        // ✅✅✅ FIN DE LA SOLUCIÓN ✅✅✅
        final int totalAlerts = controller.products.where((p) => p.status == 'Bajo' || p.status == 'Crítico').length;
        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: _buildAppBar(),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                
                // ✅ CAMBIO: Fila con Buscador + Botón Agregar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      // El buscador ocupa todo el espacio disponible
                      Expanded(
                        child: _buildSearchBar(),
                      ),
                      const SizedBox(width: 12), // Espacio entre buscador y botón
                      // Botón de agregar
                      _buildAddButton(controller),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                _buildFilters(controller),
                const SizedBox(height: 20),
                
                // --- MANEJO DE ESTADOS DE CARGA / ERROR ---
                if (controller.isLoading && controller.products.isEmpty)
                  const Center(child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ))
                else if (controller.errorMessage != null && controller.products.isEmpty)
                  Center(child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Text('Error: ${controller.errorMessage}'),
                  ))
                else
                  _buildProductsList(),
                
                const SizedBox(height: 80),
              ],
            ),
          ),
          // ✅ CAMBIO: Pasamos el 'controller'
          floatingActionButton: _buildFloatingActionButton(controller), 
          bottomNavigationBar: _buildBottomNavigationBar(totalAlerts),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    // ... (Tu código de AppBar - sin cambios)
    return AppBar(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      elevation: 0,
      // ✅ Hacemos que el botón "Home" funcione
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'InventarApp',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Gestión de Inventario',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
            icon: const Icon(Icons.logout, color: Colors.white), // Cambié el icono a 'logout' para que sea más claro
            tooltip: 'Cerrar Sesión',
            onPressed: _showLogoutDialog, // <-- Llamamos a la función
          ),
      ],
    );
  }

// ✅ Nueva función solo para el botón
  Widget _buildAddButton(ProductController controller) {
    return ElevatedButton.icon(
      onPressed: controller.isLoading ? null : _showAddProductDialog,
      icon: const Icon(Icons.add, size: 20),
      label: const Text('Agregar'),
      style: ElevatedButton.styleFrom(
        backgroundColor: controller.isLoading
            ? const Color.fromARGB(255, 0, 0, 0).withOpacity(0.5)
            : const Color.fromARGB(255, 0, 0, 0),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Bordes un poco más redondeados
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), // Misma altura que el input
        elevation: 0,
      ),
    );
  }

Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Buscar productos...',
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        // Quitamos el borde para que se vea más limpio o lo ajustamos
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintStyle: const TextStyle(color: Colors.grey),
      ),
    );
  }

  Widget _buildFilters(ProductController controller) {
    
    // ✅ Obtenemos categorías ÚNICAS de los productos cargados
    final categories = [
      'Todas las categorías', 
      ...controller.products.map((p) => p.category ?? 'Sin categoría').toSet().toList()
    ];
    
    // Los estados sí los podemos dejar hard-coded porque vienen de la API
    final statuses = ['Todos los estados', 'Óptimo', 'Bajo', 'Crítico', 'Sobrestock'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildFilterDropdown(
              selectedCategory,
              categories,
              (value) {
                setState(() {
                  selectedCategory = value;
                  _filterProducts(); // Re-filtramos
                });
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildFilterDropdown(
              selectedStatus,
              statuses,
              (value) {
                setState(() {
                  selectedStatus = value;
                  _filterProducts(); // Re-filtramos
                });
              },
            ),
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
    // ... (Tu código de Dropdown - sin cambios)
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      // Usamos DropdownButtonFormField para manejar mejor los items dinámicos
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              onChanged(newValue);
            }
          },
        ),
      ),
    );
  }

  Widget _buildProductsList() {
    // ✅ La lista a mostrar es ahora 'filteredProducts'
    if (filteredProducts.isEmpty) {
      return Center(
        // ... (Tu código para 'No hay productos' - sin cambios)
         child:Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 64,
                color: Colors.grey.shade300,
              ),
              const SizedBox(height: 16),
              Text(
                'No se encontraron productos',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        // Usamos la lista filtrada
        children: filteredProducts.map((product) {
          return _buildProductCard(product);
        }).toList(),
      ),
    );
  }
  void _showSaleDialog(Product product) {
    final _formKey = GlobalKey<FormState>();
    final quantityController = TextEditingController(text: '1');
    bool isDialogLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text('Registrar Venta'),
            content: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text('Stock actual: ${product.stock}'),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: quantityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Cantidad a Vender *'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Requerido';
                      }
                      final int? qty = int.tryParse(value);
                      if (qty == null || qty <= 0) {
                        return 'Debe ser > 0';
                      }
                      // Validamos en Flutter que no vendan más de lo que hay
                      if (qty > product.stock) {
                        return 'Stock insuficiente (Max: ${product.stock})';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: isDialogLoading ? null : () async {
                  if (!_formKey.currentState!.validate()) {
                    return;
                  }

                  setDialogState(() { isDialogLoading = true; });

                  final controller = context.read<ProductController>();
                  final int cantidad = int.parse(quantityController.text);
                  
                  // Llamamos a la nueva función del controller
                  final error = await controller.registerSale(product.id, cantidad);

                  setDialogState(() { isDialogLoading = false; });

                  if (!mounted) return;

                  if (error == null) {
                    Navigator.pop(context); // Cerramos diálogo de venta
                    _showSuccessDialog('¡Venta registrada!'); // Mostramos éxito
                  } else {
                    // Mostramos el error
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(error), backgroundColor: Colors.red),
                    );
                  }
                },
                child: Text(isDialogLoading ? 'Registrando...' : 'Vender'),
              ),
            ],
          );
        },
      ),
    );
  }

  // ✅ 6. TARJETA DE PRODUCTO ADAPTADA
  Widget _buildProductCard(Product product) {
    
    // Obtenemos el color del estado
    final Color statusColor = _getStatusColor(product.status);

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 0, 0, 0),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            // Usamos el color calculado
                            color: statusColor.withOpacity(0.1), 
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getStatusIcon(product.status),
                                size: 14,
                                color: statusColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                product.status,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: statusColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          'Categoría: ${product.category ?? "N/A"}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Stock: ${product.stock}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      // ✅ Precio es 'double', lo formateamos
                      'Precio: S/ ${product.price.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Proveedor: ${product.provider ?? "N/A"}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      // ✅ Stock Mínimo SÍ existe
                      'Stock Mín: ${product.stockMinimo ?? "N/A"}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      // ✅ Precio Compra SÍ existe
                      'P. Compra: S/ ${product.precioCompra?.toStringAsFixed(2) ?? "N/A"}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // ✅✅ NUEVO BOTÓN DE VENTA ✅✅
              IconButton(
                icon: const Icon(Icons.shopping_cart_checkout, color: Color.fromARGB(255, 0, 0, 0)),
                onPressed: () => _showSaleDialog(product), // Llama al diálogo de venta
                tooltip: 'Registrar Venta',
                constraints: const BoxConstraints(minWidth: 40),
                padding: EdgeInsets.zero,
              ),
              
              const Spacer(), // Separa el botón de venta de los otros

              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => _showProductDialog(product: product),
                constraints: const BoxConstraints(minWidth: 40),
                padding: EdgeInsets.zero,
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444)),
                onPressed: () => _deleteProduct(product),
                constraints: const BoxConstraints(minWidth: 40),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ✅ 7. AÑADIMOS LAS FUNCIONES HELPER PARA LOS ESTADOS
  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Óptimo':
        return Icons.check_circle;
      case 'Bajo':
        return Icons.warning;
      case 'Crítico':
        return Icons.error;
      case 'Sobrestock':
        return Icons.info;
      default:
        return Icons.help;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Crítico':
        return const Color(0xFFEF4444); // Rojo
      case 'Bajo':
        return Colors.orange; // Naranja
      case 'Sobrestock':
        return const Color(0xFF60A5FA); // Azul
      case 'Óptimo':
      default:
        return Colors.green; // Verde
    }
  }


Widget _buildFloatingActionButton(ProductController controller) { // <-- Acepta el controller
  return FloatingActionButton.extended(
    // ✅ Usa el 'isLoading' del controller para habilitar/deshabilitar
    onPressed: controller.isLoading ? null : _showAddProductDialog,
    backgroundColor: controller.isLoading 
        ? const Color.fromARGB(255, 0, 0, 0).withOpacity(0.5) 
        : const Color.fromARGB(255, 0, 0, 0),
    icon: const Icon(Icons.add),
    label: const Text('Agregar Producto'),
  );
}

  // ⛔ 8. DIÁLOGOS DE AGREGAR/EDITAR/ELIMINAR
  // Los dejamos aquí, pero NO los estamos llamando.
  // NECESITAN ACTUALIZARSE para coincidir con la API.

  void _showAddProductDialog() {
    _showProductDialog();
  }

  void _deleteProduct(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Producto'),
        content: Text(
            '¿Estás seguro de que deseas eliminar "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final controller = context.read<ProductController>();
              final error = await controller.deleteProduct(product.id);
              
              Navigator.pop(context); // Cerramos el diálogo de confirmación
              
              if (error == null && mounted) {
                // ✅ REQUERIMIENTO 2: Diálogo de éxito
                _showSuccessDialog('Producto eliminado exitosamente.');
              } else if (error != null && mounted) {
                // Mostramos error
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(error), backgroundColor: Colors.red),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

// --- REEMPLAZA ESTA FUNCIÓN COMPLETA ---
// --- REEMPLAZA ESTA FUNCIÓN COMPLETA ---
// --- REEMPLAZA ESTA FUNCIÓN COMPLETA ---
void _showProductDialog({Product? product}) {
  final bool isEditing = product != null;
  final _formKey = GlobalKey<FormState>();

  final productController = context.read<ProductController>();
  final List<String> categoryOptions = productController.categories;
  final List<String> providerOptions = productController.providers;

  String categoryValue = product?.category ?? '';
  String providerValue = product?.provider ?? '';
  
  final nameController = TextEditingController(text: product?.name ?? '');
  final priceController = TextEditingController(text: product?.price.toString() ?? '');
  final stockController = TextEditingController(text: product?.stock.toString() ?? '');
  final stockMinimoController = TextEditingController(text: product?.stockMinimo?.toString() ?? '5');
  final precioCompraController = TextEditingController(text: product?.precioCompra?.toString() ?? '');

  bool isDialogLoading = false;

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) {
        return AlertDialog(
          title: Text(isEditing ? 'Editar Producto' : 'Agregar Producto'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Nombre del Producto *'),
                    validator: (val) => val!.isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 12),
                  
                  // --- CAMPO DE CATEGORÍA CORREGIDO ---
                  Autocomplete<String>(
                    initialValue: TextEditingValue(text: categoryValue),
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text == '') {
                        return categoryOptions; // Muestra todas si está vacío
                      }
                      return categoryOptions.where((String option) {
                        return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                      });
                    },
                    onSelected: (String selection) {
                      setDialogState(() {
                        categoryValue = selection;
                      });
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                      return TextFormField(
                        controller: textEditingController,
                        focusNode: focusNode,
                        decoration: const InputDecoration(labelText: 'Categoría *'),
                        validator: (val) => val!.isEmpty ? 'Requerido' : null,
                        onChanged: (value) {
                          setDialogState(() {
                            categoryValue = value;
                          });
                        },
                        // ✅ ESTE ES EL CAMBIO:
                        onTap: () {
                          // Si el usuario toca el campo, lo borramos
                          // para forzar que la lista completa aparezca.
                          if (textEditingController.text.isNotEmpty) {
                            textEditingController.clear();
                            setDialogState(() {
                              categoryValue = "";
                            });
                          }
                        },
                      );
                    },
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // --- CAMPO DE PROVEEDOR CORREGIDO ---
                  Autocomplete<String>(
                    initialValue: TextEditingValue(text: providerValue),
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text == '') {
                        return providerOptions; // Muestra todos si está vacío
                      }
                      return providerOptions.where((String option) {
                        return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                      });
                    },
                    onSelected: (String selection) {
                      setDialogState(() {
                        providerValue = selection;
                      });
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                      return TextFormField(
                        controller: textEditingController,
                        focusNode: focusNode,
                        decoration: const InputDecoration(labelText: 'Proveedor *'),
                        validator: (val) => val!.isEmpty ? 'Requerido' : null,
                        onChanged: (value) {
                          setDialogState(() {
                            providerValue = value;
                          });
                        },
                        // ✅ ESTE ES EL CAMBIO:
                        onTap: () {
                          // Si el usuario toca el campo, lo borramos
                          // para forzar que la lista completa aparezca.
                          if (textEditingController.text.isNotEmpty) {
                            textEditingController.clear();
                            setDialogState(() {
                              providerValue = "";
                            });
                          }
                        },
                      );
                    },
                  ),
                  
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: priceController,
                    decoration: const InputDecoration(labelText: 'Precio de Venta *', prefixText: 'S/ '),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (val) => val!.isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: stockController,
                    decoration: const InputDecoration(labelText: 'Stock Actual *'),
                    keyboardType: TextInputType.number,
                    validator: (val) => val!.isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: stockMinimoController,
                    decoration: const InputDecoration(labelText: 'Stock Mínimo'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: precioCompraController,
                    decoration: const InputDecoration(labelText: 'Precio de Compra', prefixText: 'S/ '),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              child: Text(isDialogLoading ? 'Guardando...' : 'Guardar'),
              onPressed: isDialogLoading ? null : () async {
                if (!_formKey.currentState!.validate()) {
                  return;
                }

                setDialogState(() {
                  isDialogLoading = true;
                });

                final productData = {
                  'name': nameController.text,
                  'category': categoryValue,
                  'provider': providerValue,
                  'price': double.tryParse(priceController.text) ?? 0.0,
                  'stock': int.tryParse(stockController.text) ?? 0,
                  'stock_minimo': int.tryParse(stockMinimoController.text) ?? 5,
                  'precio_compra': double.tryParse(precioCompraController.text) ?? 0.0,
                };

                final controller = context.read<ProductController>();
                String? error;

                if (isEditing) {
                  error = await controller.updateProduct(product!.id, productData);
                } else {
                  error = await controller.addProduct(productData);
                }
                
                setDialogState(() {
                  isDialogLoading = false;
                });

                if (!mounted) return;
                
                if (error == null) {
                  Navigator.pop(context); // Éxito, cerramos el diálogo
                  _showSuccessDialog(isEditing ? 'Producto actualizado' : 'Producto agregado');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(error), backgroundColor: Colors.red),
                  );
                }
              },
            ),
          ],
        );
      },
    ),
  );
}
  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 10),
            Text('Éxito'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }


  Widget _buildBottomNavigationBar(int totalAlerts) {
    // ... (Tu código de BottomNav - sin cambios)
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 0, 0, 0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, 'Inicio', 0, totalAlerts),
              _buildNavItem(Icons.inventory_2_outlined, 'Inventario', 1, totalAlerts),
              _buildNavItem(Icons.trending_up, 'Predicción', 2, totalAlerts),
              _buildNavItem(Icons.notifications_outlined, 'Alertas', 3, totalAlerts),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildNavItem(IconData icon, String label, int index, int totalAlerts) {
    // ... (Tu código de NavItem - sin cambios)
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        if (_selectedIndex != index) {
          // Si tocamos "Inicio" (índice 0)
          if (index == 0) {
            // Simplemente volvemos, ya que Home es la pantalla anterior
            Navigator.pop(context); 
          } else if (index == 2){
            Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PredictionScreen()),
            );
          }
          else if (index == 3) { 
          // ✅ IR A ALERTAS
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NotificationsScreen()),
            );
          } 
          else {
            // Para otros íconos, solo actualizamos el estado por ahora
            setState(() {
              _selectedIndex = index;
            });
          }
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(12), // Tu 'inventario.dart' usa 12
            ),
            // ✅ ENVUELVE EL ICONO CON UN STACK
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  color: isSelected ? const Color(0xFF0A0E27) : Colors.white, // Color de texto seleccionado
                  size: 24,
                ),
                // ✅ LÓGICA DEL BADGE
                if (index == 3 && totalAlerts > 0)
                  Positioned(
                    right: -25, // Ajusta esto para tu diseño
                    top: -10,   // Ajusta esto para tu diseño
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444), // Rojo
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        '$totalAlerts',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label, 
            style: TextStyle(
              color: Colors.white, // <--- CAMBIO REALIZADO
              fontSize: 11, 
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
            )
          ),
        ],
      ),
    );
  }
}

// ⛔ 9. ELIMINAMOS LA CLASE 'Product' DE AQUÍ
// class Product { ... }