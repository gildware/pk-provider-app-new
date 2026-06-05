import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';
class InputBoxView extends StatefulWidget {
  final TextEditingController? inputAmountController;
  final FocusNode? focusNode;
  final double? amount;

  const InputBoxView({
    super.key,
    required this.inputAmountController, this.focusNode,this.amount
  });

  @override
  State<InputBoxView> createState() => _InputBoxViewState();
}

class _InputBoxViewState extends State<InputBoxView> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }
  bool isTextFieldEmpty = true;

  @override
  Widget build(BuildContext context) {
    double maxWithdrawAmount = 878787888888;
    double minimumWithdrawAmount = Get.find<SplashController>().configModel.content?.minimumWithdrawAmount??100;
    List<double> suggestInputAmountList = [];
    if(widget.amount!=null){
      suggestInputAmountList.add(minimumWithdrawAmount);
      if(widget.amount!>500&& 500<=maxWithdrawAmount){
        suggestInputAmountList.add(500);
      }
      if(widget.amount!>1000 && 1000<=maxWithdrawAmount){
        suggestInputAmountList.add(1000);
      }
      if(widget.amount!>5000&& 5000<=maxWithdrawAmount){
        suggestInputAmountList.add(5000);
      }
      if(widget.amount!>10000&& 10000<=maxWithdrawAmount){
        suggestInputAmountList.add(10000);
      }
      if(widget.amount!>20000&& 20000<=maxWithdrawAmount){
        suggestInputAmountList.add(20000);
      }
      if(widget.amount!>50000&& 50000<=maxWithdrawAmount){
        suggestInputAmountList.add(50000);
      }
      if(widget.amount!>100000&& 100000<=maxWithdrawAmount){
        suggestInputAmountList.add(100000);
      }
      if(widget.amount!>500000&& 500000<=maxWithdrawAmount){
        suggestInputAmountList.add(500000);
      }
      if(widget.amount! < maxWithdrawAmount){
        suggestInputAmountList.add(widget.amount!);
      }
      suggestInputAmountList.sort();
    }
    bool isRightSide = Get.find<SplashController>().configModel.content?.currencySymbolPosition == 'right';

    return GetBuilder<TransactionController>(
        builder: (transactionMoneyController) {
          return Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GetBuilder<TransactionController>(
                builder: (controller) => Column(children: [
                  Stack(children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: Dimensions.paddingSizeDefault*2,),
                      Row(mainAxisAlignment : MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Expanded(child: SizedBox()),
                          if(!isRightSide)
                          Text(PriceConverter.getCurrency(),
                            style: robotoBold.copyWith(
                              fontSize: 20,
                              color: isTextFieldEmpty
                                  ?Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha:0.5)
                                  :Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha:0.8),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: IntrinsicWidth(
                              child: TextFormField(
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(20),
                                ],
                              keyboardType: TextInputType.number,
                              controller: widget.inputAmountController,
                              focusNode: widget.focusNode,
                              textAlignVertical: TextAlignVertical.center,
                              textAlign: TextAlign.center,
                                maxLines: 1,
                                decoration: InputDecoration(
                                  border : InputBorder.none,
                                  isCollapsed: true,
                                  hintText: "0.0",
                                  hintStyle: robotoBold.copyWith(
                                      fontSize: 20,
                                    color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha:0.5)
                                  )
                                ),
                                style: robotoBold.copyWith(fontSize: 20,color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha:0.8)),
                                onChanged: (String value){
                                  setState(() {
                                    if(value.isNotEmpty){
                                      isTextFieldEmpty = false;
                                    }else{
                                      isTextFieldEmpty = true;
                                    }
                                  });
                                },
                              ),
                            ),
                          ),
                          if(isRightSide)
                          Text(PriceConverter.getCurrency(),
                            style: robotoBold.copyWith(
                              fontSize: 20,
                              color: isTextFieldEmpty ?
                              Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha:0.5) :
                              Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha:0.8),
                            ),
                          ),

                          const Expanded(child: SizedBox()),
                        ],
                      ),
                      const SizedBox(height: Dimensions.paddingSizeSmall,),
                      Divider(height: 0.5, color: Theme.of(context).hintColor,),
                      const SizedBox(height: Dimensions.paddingSizeSmall,),
                      Row(
                        children: [
                          Text("available_balance".tr,style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha:0.5)),),
                          const SizedBox(width: Dimensions.paddingSizeExtraSmall,),
                          Text(PriceConverter.convertPrice(widget.amount),
                            style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha:0.5)),)
                        ],
                      ),
                        if(Get.find<SplashController>().configModel.content?.minimumWithdrawAmount!=null)
                        const SizedBox(height: Dimensions.paddingSizeSmall,),
                        if(Get.find<SplashController>().configModel.content?.minimumWithdrawAmount!=null)
                        Row(
                          children: [
                            Text("minimum_withdraw_amount".tr,style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha:0.5)),),
                            const SizedBox(width: Dimensions.paddingSizeExtraSmall,),
                            Text(PriceConverter.convertPrice(Get.find<SplashController>().configModel.content?.minimumWithdrawAmount),
                              style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha:0.5)),)
                          ],
                        ),

                        if(Get.find<SplashController>().configModel.content?.maximumWithdrawAmount!=null)
                          const SizedBox(height: Dimensions.paddingSizeSmall,),
                        if(Get.find<SplashController>().configModel.content?.maximumWithdrawAmount!=null)
                        Row(
                          children: [
                            Text("maximum_withdraw_amount".tr,style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha:0.5)),),
                            const SizedBox(width: Dimensions.paddingSizeExtraSmall,),
                            Text(PriceConverter.convertPrice(Get.find<SplashController>().configModel.content?.maximumWithdrawAmount),
                              style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha:0.5)),)
                          ],
                        ),
                      const SizedBox(height: Dimensions.paddingSizeDefault,),
                      Column(
                        children: [
                          GetBuilder<TransactionController>(
                            builder: (transactionController) {
                              return SizedBox(height: 30,
                                child: ListView.builder(itemCount: suggestInputAmountList.length,
                                    scrollDirection: Axis.horizontal,
                                    padding: EdgeInsets.zero,
                                    itemBuilder: (cnt, index){
                                  return GestureDetector(
                                    onTap: (){
                                      transactionController.setIndex(index, suggestInputAmountList[index].toString());
                                      widget.inputAmountController!.text = suggestInputAmountList[index].toString();
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                                      margin:  EdgeInsets.only(
                                        right: Get.find<LocalizationController>().isLtr ? 10 : 0 ,
                                        left : Get.find<LocalizationController>().isLtr ? 0 : 10 ,
                                      ),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: Get.find<TransactionController>().selectAmount != null ?
                                        suggestInputAmountList[index].toString() == Get.find<TransactionController>().selectAmount
                                            ? Theme.of(context).primaryColorLight
                                            : Theme.of(context).cardColor :  Theme.of(context).cardColor,

                                        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                                        border: Border.all(width: 0.5,color: Theme.of(context).primaryColorLight),
                                      ),

                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: Dimensions.paddingSizeDefault,
                                          vertical: Dimensions.paddingSizeExtraSmall,
                                        ),
                                        child: Text(isRightSide?suggestInputAmountList[index].toString()+PriceConverter.getCurrency()
                                            :PriceConverter.getCurrency()+suggestInputAmountList[index].toString(),
                                          style: robotoRegular.copyWith(
                                              fontSize: Dimensions.fontSizeDefault,
                                              color: suggestInputAmountList[index].toString() == transactionController.selectAmount
                                                  ? Theme.of(context).cardColor
                                                  : Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha:0.7)
                                          ),
                                        ),
                                      ),
                                    ),

                                  );
                                }),
                              );
                            }
                          ),
                        ],
                      ),
                      ],
                    ),
                  ],
                  ),
                ],
                ),
              ),
            ],
          );
        }
    );
  }
}
