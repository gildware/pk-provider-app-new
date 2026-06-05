import 'package:demandium_provider/util/core_export.dart';
import 'package:demandium_provider/feature/custom_post/model/post_model.dart';
import 'package:get/get.dart';

class CustomPostListview extends StatelessWidget {
  final List<PostData> myPost;
  final bool newRequest;
  const CustomPostListview({super.key, required this.myPost, required this.newRequest});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PostController>(
        builder: (postController) {
        return Padding(padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeDefault,10,15,10),
          child: postController.loading?
          const Center(child: CircularProgressIndicator()):
          CustomScrollView(
            controller: postController.scrollController,
            slivers: [
            SliverToBoxAdapter(child: Column(
              children: [

                !postController.loading && myPost.isNotEmpty?
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context,index){
                    return CustomerBookingAcceptView(postData: myPost[index]);
                  },
                  itemCount: myPost.length,
                ): SizedBox(height: Get.height*0.75,
                  child: Center(
                    child: NoDataScreen(
                      text: "",
                      type: newRequest ? NoDataType.customPost : NoDataType.myBids,
                    ),
                  ),),

                if(postController.isLoading)
                  const CircularProgressIndicator()
              ],
            ),)
          ],),
        );
    });
  }
}
