import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/image_controller.dart';
import '../../controller/translate_controller.dart';
import '../../helper/global.dart';
import '../../widget/custom_btn.dart';
import '../../widget/custom_loading.dart';
import '../../widget/language_sheet.dart';

class TranslatorFeature extends StatefulWidget {
  const TranslatorFeature({super.key});

  @override
  State<TranslatorFeature> createState() => _TranslatorFeatureState();
}

class _TranslatorFeatureState extends State<TranslatorFeature> {
  final _c = TranslateController();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Language Translator',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Theme.of(context).primaryColor,
          ),
        ),
      ),

      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.all(mq.width * .04),
          child: Column(
            children: [
              // Language Selection Cards
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // From Language
                    Expanded(
                      child: InkWell(
                        onTap: () => Get.bottomSheet(LanguageSheet(c: _c, s: _c.from)),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[700] : Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: Theme.of(context).primaryColor.withOpacity(0.3),
                            ),
                          ),
                          child: Obx(() => Text(
                            _c.from.isEmpty ? 'Auto' : _c.from.value,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          )),
                        ),
                      ),
                    ),

                    // Swap Button
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: _c.swapLanguages,
                        icon: Obx(() => Icon(
                          Icons.swap_horiz_rounded,
                          color: _c.to.isNotEmpty && _c.from.isNotEmpty
                              ? Theme.of(context).primaryColor
                              : Colors.grey,
                          size: 28,
                        )),
                      ),
                    ),

                    // To Language
                    Expanded(
                      child: InkWell(
                        onTap: () => Get.bottomSheet(LanguageSheet(c: _c, s: _c.to)),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[700] : Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: Theme.of(context).primaryColor.withOpacity(0.3),
                            ),
                          ),
                          child: Obx(() => Text(
                            _c.to.isEmpty ? 'Select' : _c.to.value,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          )),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Input Text Field
              Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: _c.textC,
                  minLines: 5,
                  maxLines: 8,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter text to translate...',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(20),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Translation Result
              Obx(() => switch (_c.status.value) {
                Status.none => const SizedBox(),
                Status.loading => Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CustomLoading(),
                  ),
                ),
                Status.complete => Container(
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[800] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    controller: _c.resultC,
                    minLines: 5,
                    maxLines: 8,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(20),
                      suffixIcon: IconButton(
                        icon: Icon(
                          Icons.copy_rounded,
                          color: Theme.of(context).primaryColor,
                        ),
                        onPressed: () {
                          // Add copy functionality
                        },
                      ),
                    ),
                  ),
                ),
              }),

              const SizedBox(height: 20),

              // Translate Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _c.googleTranslate,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                    shadowColor: Theme.of(context).primaryColor.withOpacity(0.5),
                  ),
                  child: Text(
                    'Translate',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
