import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Models/product_model.dart';
import '../widgets/product_card.dart';
import 'product_detail_page.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {

  List<ProductModel> products = [];

  @override
  void initState() {
    super.initState();
    loadProducts();
  }


  Future<void> loadProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final productsList = prefs.getStringList('products') ?? [];
    setState(() {
      products = productsList.map((item) => ProductModel.fromJson(item)).toList();
    });
  }

  Future<void> saveProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final productsList = products.map((p) => p.toJson()).toList();
    await prefs.setStringList('products', productsList);
  }

  Future<void> addProduct(ProductModel product) async {
    setState(() => products.add(product));
    await saveProducts();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Produk berhasil ditambahkan')),
    );
  }

  Future<void> editProduct(int index, ProductModel updatedProduct) async {
    setState(() => products[index] = updatedProduct);
    await saveProducts();
  }

  Future<void> deleteProduct(int index) async {
    setState(() => products.removeAt(index));
    await saveProducts();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Produk berhasil dihapus')),
    );
  }

  void showForm({ProductModel? product, int? index}) {
    final nameController = TextEditingController(text: product?.name ?? '');
    final descriptionController = TextEditingController(text: product?.description ?? '');
    final priceController = TextEditingController(text: product != null ? product.price.toString() : '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(product == null ? 'Tambah Produk' : 'Edit Produk'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nama Produk')),
              const SizedBox(height: 8),
              TextField(controller: descriptionController, decoration: const InputDecoration(labelText: 'Deskripsi Produk')),
              const SizedBox(height: 8),
              TextField(controller: priceController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Harga Produk')),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                nameController.dispose();
                descriptionController.dispose();
                priceController.dispose();
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                final newProduct = ProductModel(
                  name: nameController.text,
                  description: descriptionController.text,
                  price: double.tryParse(priceController.text) ?? 0.0,
                );
                if (product == null) {
                  addProduct(newProduct);
                } else {
                  editProduct(index!, newProduct);
                }
                Navigator.pop(context);
                nameController.dispose();
                descriptionController.dispose();
                priceController.dispose();
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        title: const Text('Daftar Produk'),
        backgroundColor: Colors.green,
        elevation: 0,
      ),

      body: Container(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Expanded(
              child: products.isEmpty
                  ? const Center(child: Text('Belum ada produk'))
                  : ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];

                        return ProductCard(
                          product: product,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => ProductDetailPage(product: product)),
                            );
                          },
                          onEdit: () => showForm(product: product, index: index),
                          onDelete: () => deleteProduct(index),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => showForm(),
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }
}