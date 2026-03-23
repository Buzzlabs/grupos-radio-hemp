import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fluffychat/config/themes.dart';
import 'package:fluffychat/widgets/layouts/max_width_body.dart';
import 'bundle_form.dart';

class BundleFormView extends StatelessWidget {
  final BundleFormController controller;

  const BundleFormView(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: controller.loading
            ? null
            : () => context.go("/rooms/discover"),
          color: theme.colorScheme.newBundleTextColor,
        ),
        title: Text(
          controller.isEdit ? "Editar Bundle" : "Criar Bundle",
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

                  /// NAME
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: TextField(
                      readOnly: controller.loading, 
                      controller: controller.nameController,
                      style: TextStyle(
                        color: theme.colorScheme.newBundleTextColor,
                      ),
                      decoration: InputDecoration(
                        fillColor:
                            theme.colorScheme.newBundleTextFieldFillColor,
                        hintStyle: TextStyle(
                          color: theme
                              .colorScheme.newBundleTextFieldHintTextColor,
                        ),
                        prefixIcon: const Icon(Icons.inventory_2_outlined),
                        labelText: "Nome do bundle",
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// PRICE
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: TextField(
                      readOnly: controller.loading, 
                      controller: controller.priceController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(
                        color: theme.colorScheme.newBundleTextColor,
                      ),
                      decoration: InputDecoration(
                        fillColor:
                            theme.colorScheme.newBundleTextFieldFillColor,
                        hintStyle: TextStyle(
                          color: theme
                              .colorScheme.newBundleTextFieldHintTextColor,
                        ),
                        prefixIcon: const Icon(Icons.attach_money_outlined),
                        labelText: "Preço",
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// ROOMS
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
                            title: Text(
                              room.name,
                              style: TextStyle(
                                color: theme
                                    .colorScheme.newBundleSelectNameTextColor,
                              ),
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                Icons.close,
                                color: theme
                                    .colorScheme.newBundleButtonTextColor,
                              ),
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

                  /// BUTTON
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
                            : Text(
                                controller.isEdit
                                    ? "Salvar alterações"
                                    : "Criar Bundle",
                                style: TextStyle(
                                  color: theme
                                      .colorScheme.newBundleButtonTextColor,
                                ),
                              ),
                      ),
                    ),
                  ),

                  /// ERROR
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