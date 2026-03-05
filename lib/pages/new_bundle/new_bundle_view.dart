import 'package:flutter/material.dart';
import 'package:fluffychat/config/themes.dart';
import 'package:fluffychat/widgets/layouts/max_width_body.dart';
import 'package:fluffychat/pages/new_bundle/new_bundle.dart';

class CreateBundleView extends StatelessWidget {
  final CreateBundleController controller;

  const CreateBundleView(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: Center(
          child: BackButton(
            onPressed:
                controller.loading ? null : () => Navigator.of(context).pop(),
            color: theme.colorScheme.newBundleTextColor,
          ),
        ),
        title: Text(
          "Criar Bundle",
          style: TextStyle(color: theme.colorScheme.newBundleTextColor),
        ),
      ),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final error = controller.error;

          return MaxWidthBody(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 24),

                  /// NOME
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: TextField(
                      style: TextStyle(
                  color: theme.colorScheme.newBundleTextColor,),
                      controller: controller.nameController,
                      readOnly: controller.loading,
                      decoration:  InputDecoration(
                        fillColor: theme.colorScheme.newBundleTextFieldFillColor ,
                        hintStyle: TextStyle(color: theme.colorScheme.newBundleTextFieldHintTextColor),
                        prefixIcon: const Icon(Icons.inventory_2_outlined),
                        labelText: "Nome do bundle",
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// PREÇO
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: TextField(
                      style: TextStyle(
                  color: theme.colorScheme.newBundleTextColor,),
                      controller: controller.priceController,
                      readOnly: controller.loading,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        fillColor: theme.colorScheme.newBundleTextFieldFillColor ,
                        hintStyle: TextStyle(color: theme.colorScheme.newBundleTextFieldHintTextColor),
                        prefixIcon: const Icon(Icons.attach_money_outlined),
                        labelText: "Preço",
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// SALAS
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Salas incluídas (opcional)",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),

                        ...controller.selectedRooms.map(
                          (room) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(room.name ?? room.id, style: TextStyle(color: theme.colorScheme.newBundleSelectNameTextColor)),
                            trailing: IconButton(
                              icon: Icon(Icons.close, color: theme.colorScheme.newBundleButtonTextColor),
                              onPressed: controller.loading
                                  ? null
                                  : () => controller.removeRoom(room),
                            ),
                          ),
                        ),

                        TextButton.icon(
                          onPressed: controller.loading
                              ? null
                              : () => controller.selectRooms(context),
                          icon: const Icon(Icons.add),
                          label: const Text("Adicionar salas"),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  /// BOTÃO
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: controller.loading
                            ? null
                            : () => controller.submit(context),
                        child: controller.loading
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text("Criar Bundle",style: TextStyle(color: theme.colorScheme.newBundleButtonTextColor),),
                      ),
                    ),
                  ),

                  /// ERRO
                  AnimatedSize(
                    duration: FluffyThemes.animationDuration,
                    curve: FluffyThemes.animationCurve,
                    child: error == null
                        ? const SizedBox.shrink()
                        : ListTile(
                            leading: Icon(
                              Icons.warning_outlined,
                              color: theme.colorScheme.error,
                            ),
                            title: Text(
                              error,
                              style: TextStyle(
                                color: theme.colorScheme.error,
                              ),
                            ),
                          ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}