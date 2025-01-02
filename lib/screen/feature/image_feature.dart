import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../controller/image_controller.dart';
import '../../helper/global.dart';
import '../../widget/custom_btn.dart';
import '../../widget/custom_loading.dart';

class ImageFeature extends StatefulWidget {
  const ImageFeature({super.key});

  @override
  State<ImageFeature> createState() => _ImageFeatureState();
}

class _ImageFeatureState extends State<ImageFeature> {
  final _c = ImageController();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'AI Image Creator',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Theme.of(context).primaryColor,
          ),
        ),
        actions: [
          Obx(() => _c.status.value == Status.complete
              ? Row(
                  children: [
                    IconButton(
                      onPressed: _c.shareImage,
                      icon: Icon(
                        Icons.share_rounded,
                        color: isDark ? Colors.white : Theme.of(context).primaryColor,
                      ),
                    ),
                    IconButton(
                      onPressed: _c.downloadImage,
                      icon: Icon(
                        Icons.save_alt_rounded,
                        color: isDark ? Colors.white : Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                )
              : const SizedBox()),
        ],
      ),

      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.all(mq.width * .04),
          child: Column(
            children: [
              // Input Field
              Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(15),
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
                  minLines: 3,
                  maxLines: 5,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Describe your imagination...\nBe creative! 🎨',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(20),
                  ),
                ),
              ),

              // Generated Image
              Container(
                height: mq.height * .5,
                margin: EdgeInsets.symmetric(vertical: mq.height * .03),
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
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Obx(() => _aiImage()),
                ),
              ),

              // Previous Images
              Obx(() => _c.imageList.isEmpty
                  ? const SizedBox()
                  : Container(
                      height: 120,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[800] : Colors.grey[100],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(10),
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: _c.imageList.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () => _c.url.value = _c.imageList[index],
                            child: Container(
                              width: 100,
                              margin: const EdgeInsets.only(right: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _c.url.value == _c.imageList[index]
                                      ? Theme.of(context).primaryColor
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: CachedNetworkImage(
                                  imageUrl: _c.imageList[index],
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    color: isDark ? Colors.grey[700] : Colors.grey[300],
                                  ),
                                  errorWidget: (context, url, error) => const SizedBox(),
                                ),
                              ),
                            ),
                          ).animate().fadeIn().slideX();
                        },
                      ),
                    )),

              // Create Button
              Container(
                margin: const EdgeInsets.only(top: 20),
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _c.searchAiImage,
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
                    'Create Magic ✨',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.white,
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

 Widget _aiImage() => ClipRRect(
  borderRadius: BorderRadius.circular(20),
  child: switch (_c.status.value) {
    Status.none => Center(
      child: Lottie.asset(
        'assets/lottie/ai_play.json',
        height: mq.height * .3,
      ),
    ),
    Status.complete => CachedNetworkImage(
      imageUrl: _c.url.value,
      fit: BoxFit.cover,
      placeholder: (context, url) => const CustomLoading(),
      errorWidget: (context, url, error) => const SizedBox(),
    ),
    Status.loading => const CustomLoading()
  },
);
}
