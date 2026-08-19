//
//  HKCFieldAlertController
    

import UIKit

class HKCFieldAlertViewModel{
    var contentBGColor:UIColor = UIColor.white
    var contentShadowColor:UIColor = UIColor.black
    var contentTitleColor:UIColor = UIColor.black
    var contentMessageColor:UIColor = UIColor(red: 34.0/255.0, green: 34.0/255.0, blue: 34.0/255.0, alpha: 1)
    var contentFieldTintColor:UIColor = UIColor .black
    var contentFieldCornerRadius:CGFloat = 20.0
    var contentFieldBGColor = UIColor.white
    var contentFieldBoardColor:UIColor?
    var contentPlaceHolderColor:UIColor?
    var contentCornerRadius:CGFloat = 24.0
    var titleFont:UIFont = UIFont.systemFont(ofSize: 17.0, weight: .semibold)
    var messageFont:UIFont = UIFont.systemFont(ofSize: 14.0, weight: .regular)
    var fieldFont:UIFont = UIFont.systemFont(ofSize: 15.0, weight: .regular)
    var buttonTitleFont:UIFont = UIFont.systemFont(ofSize: 16.0, weight: .medium)
    var cancelButtonTitleColor:UIColor = UIColor(red: 43.0/255.0, green: 43.0/255.0, blue: 43.0/255.0, alpha: 1)
    var ensureButtonTitleColor:UIColor = UIColor(red: 1.0, green: 117.0/255.0, blue: 183.0/255.0, alpha: 1)
    var separatorColor:UIColor = UIColor(red: 232.0/255.0, green: 232.0/255.0, blue: 232.0/255.0, alpha: 1)
    
}


class HKCFieldAlertController: UIViewController, UIGestureRecognizerDelegate {
    public var offsetY:CGFloat = 0

    private var contentView:UIView = UIView()
    private var cancelButton:UIButton = UIButton()
    private var ensureButton:UIButton = UIButton()
    private var fieldsContainer:[UITextField] = []
    private var contentTitle:String?
    private var contentTMessage:String?
    private var contentTitleLabel:UILabel?
    private var contentTMessageLabel:UILabel?
    private var ensureClosure:(( _ fields:[UITextField])->())?
    private var separatorLine:UIView = UIView()
    private var buttonTopLine:UIView = UIView()
    private var contentViewCenterY:CGFloat = 0
    private var isContentVisible = false
    public var alertCancelButton:UIButton{
        get{
            return cancelButton
        }
    }
    
    public var minContentViewHeight:CGFloat = 224.0
    public var padding:CGFloat = 34.0
    
    
    public var alertEnsureButton:UIButton{
        get{
            return ensureButton
        }
    }
    
    public var viewModel = HKCFieldAlertViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0)
        setUpContentView()
        
        view.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapNullAreaViewGesture))
        tap.delegate = self
        view.addGestureRecognizer(tap)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardFrameWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func tapNullAreaViewGesture(){
        contentClose()
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool{
        let location = gestureRecognizer.location(in: view)
        
        if CGRectContainsPoint(contentView.frame, location){
            return false
        }
        return true
    }
    
    private func setUpContentView(){
        contentView.bounds = CGRectMake(0, 0, view.bounds.width - padding*2, minContentViewHeight)
        contentView.backgroundColor = viewModel.contentBGColor
        contentView.layer.cornerRadius = viewModel.contentCornerRadius
        contentView.layer.masksToBounds = false
        contentView.layer.shadowColor = viewModel.contentShadowColor.withAlphaComponent(0.35).cgColor
        contentView.layer.shadowRadius = 4.0
        contentView.layer.shadowOffset = CGSize(width: 0, height: 0)
        contentView.layer.shadowOpacity = 1
        contentView.center = view.center
        view.addSubview(contentView)
        contentView.alpha = 0
        contentView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.92, 0.92)
        
        if contentTitle != nil && contentTitle!.count > 0 {
            setUpTitleLabel()
        }
        
        if contentTMessage != nil && contentTMessage!.count > 0 {
            setUpMessageLabel()
        }
        
        for field in fieldsContainer {
            configureField(field)
            contentView.addSubview(field)
        }
        
        setUpActionButtons()
    }
    
    private func setUpTitleLabel(){
        contentTitleLabel = UILabel()
        contentTitleLabel!.font = viewModel.titleFont
        contentTitleLabel!.textColor = viewModel.contentTitleColor
        contentTitleLabel!.text = contentTitle
        contentTitleLabel!.textAlignment = .center
        contentTitleLabel!.numberOfLines = 0
        contentView.addSubview(contentTitleLabel!)
    }
    
    private func setUpMessageLabel(){
        contentTMessageLabel = UILabel()
        contentTMessageLabel!.font = viewModel.messageFont
        contentTMessageLabel!.textColor = viewModel.contentMessageColor
        contentTMessageLabel!.text = contentTMessage
        contentTMessageLabel!.textAlignment = .center
        contentTMessageLabel!.numberOfLines = 0
        contentView.addSubview(contentTMessageLabel!)
    }
    
    private func setUpActionButtons(){
        buttonTopLine.backgroundColor = viewModel.separatorColor
        contentView.addSubview(buttonTopLine)
        
        separatorLine.backgroundColor = viewModel.separatorColor
        contentView.addSubview(separatorLine)
        
        cancelButton.setTitle("取消", for: .normal)
        cancelButton.titleLabel?.font = viewModel.buttonTitleFont
        cancelButton.setTitleColor(viewModel.cancelButtonTitleColor, for: .normal)
        cancelButton.addTarget(self, action: #selector(clickCancelButton), for: .touchUpInside)
        contentView.addSubview(cancelButton)
        
        ensureButton.setTitle("确定", for: .normal)
        ensureButton.titleLabel?.font = viewModel.buttonTitleFont
        ensureButton.setTitleColor(viewModel.ensureButtonTitleColor, for: .normal)
        ensureButton.addTarget(self, action: #selector(clickEnsureButton), for: .touchUpInside)
        contentView.addSubview(ensureButton)
    }
    
    class func alertControllerWithTitleAndMessage(title:String? = nil,
                                                  message:String? = nil,
                                                  _ ensureClosure:(( _ fields:[UITextField])->())? = nil)->HKCFieldAlertController{
        let alertController = HKCFieldAlertController()
        alertController.contentTitle = title
        alertController.contentTMessage = message
        alertController.ensureClosure = ensureClosure
        alertController.modalPresentationStyle = .overFullScreen
        alertController.modalTransitionStyle = .crossDissolve
        return alertController
    }
    
    public func addFieldWithPlaceholder(placeholder:String,
                                        tag:NSInteger,
                                        callBackClosure:((_ filed:UITextField)->())? = nil){
        let textField = UITextField()
        textField.tag = tag
        configureField(textField)
        
        if viewModel.contentPlaceHolderColor != nil {
            textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [.foregroundColor:viewModel.contentPlaceHolderColor!])
        } else {
            textField.placeholder = placeholder
        }
        
        callBackClosure?(textField)
        fieldsContainer.append(textField)
        
        if isViewLoaded {
            contentView.addSubview(textField)
            view.setNeedsLayout()
        }
    }
    
    private func configureField(_ textField:UITextField){
        textField.font = viewModel.fieldFont
        textField.textColor = viewModel.contentFieldTintColor
        textField.tintColor = viewModel.contentFieldTintColor
        textField.backgroundColor = viewModel.contentFieldBGColor
        textField.layer.cornerRadius = viewModel.contentFieldCornerRadius
        textField.layer.masksToBounds = true
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .done
        textField.leftView = UIView(frame: CGRectMake(0, 0, 14.0, 1.0))
        textField.leftViewMode = .always
        textField.delegate = self
        
        if viewModel.contentFieldBoardColor != nil {
            textField.layer.borderColor = viewModel.contentFieldBoardColor!.cgColor
            textField.layer.borderWidth = 1.0
        } else {
            textField.layer.borderColor = nil
            textField.layer.borderWidth = 0
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        layoutContentView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        contentShowAnimation()
    }
    
    private func layoutContentView(){
        let contentWidth = max(view.bounds.width - padding*2.0, 260.0)
        let horizontalMargin:CGFloat = 22.0
        let fieldHeight:CGFloat = 44.0
        let fieldSpacing:CGFloat = 12.0
        let buttonHeight:CGFloat = 52.0
        let lineHeight = 1.0 / UIScreen.main.scale
        var beginOriginY:CGFloat = 24.0
        
        if contentTitleLabel != nil {
            let maxTitleWidth = contentWidth - horizontalMargin*2.0
            let titleSize = contentTitleLabel!.sizeThatFits(CGSizeMake(maxTitleWidth, CGFloat(MAXFLOAT)))
            contentTitleLabel!.frame = CGRectMake(horizontalMargin,
                                                  beginOriginY,
                                                  maxTitleWidth,
                                                  ceil(titleSize.height))
            beginOriginY = CGRectGetMaxY(contentTitleLabel!.frame) + 10.0
        }
        
        if contentTMessageLabel != nil {
            let maxMessageWidth = contentWidth - horizontalMargin*2.0
            let messageSize = contentTMessageLabel!.sizeThatFits(CGSizeMake(maxMessageWidth, CGFloat(MAXFLOAT)))
            contentTMessageLabel!.frame = CGRectMake(horizontalMargin,
                                                     beginOriginY,
                                                     maxMessageWidth,
                                                     ceil(messageSize.height))
            beginOriginY = CGRectGetMaxY(contentTMessageLabel!.frame) + 20.0
        }
        
        if fieldsContainer.count == 0 && contentTitleLabel == nil && contentTMessageLabel == nil {
            beginOriginY = 28.0
        }
        
        for field in fieldsContainer {
            field.frame = CGRectMake(horizontalMargin,
                                     beginOriginY,
                                     contentWidth - horizontalMargin*2.0,
                                     fieldHeight)
            beginOriginY = CGRectGetMaxY(field.frame) + fieldSpacing
        }
        
        if fieldsContainer.count > 0 {
            beginOriginY += 8.0 - fieldSpacing
        }
        
        let contentHeight = max(beginOriginY + buttonHeight, minContentViewHeight)
        contentView.bounds = CGRectMake(0, 0, contentWidth, contentHeight)
        contentViewCenterY = view.bounds.midY - offsetY
        contentView.center = CGPoint(x: view.bounds.midX, y: contentViewCenterY)
        
        buttonTopLine.frame = CGRectMake(0, contentHeight - buttonHeight, contentWidth, lineHeight)
        separatorLine.frame = CGRectMake(contentWidth * 0.5, contentHeight - buttonHeight, lineHeight, buttonHeight)
        cancelButton.frame = CGRectMake(0, contentHeight - buttonHeight, contentWidth * 0.5, buttonHeight)
        ensureButton.frame = CGRectMake(contentWidth * 0.5, contentHeight - buttonHeight, contentWidth * 0.5, buttonHeight)
    }
    
    @objc private func clickCancelButton(){
        contentClose()
    }
    
    @objc private func clickEnsureButton(){
        let ensureClosure = ensureClosure
        contentClose {
            ensureClosure?(self.fieldsContainer)
        }
    }
    
    @objc private func keyboardFrameWillChange(notification:Notification){
        guard isContentVisible,
              let keyboardFrameValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardFrame = keyboardFrameValue.cgRectValue
        let keyboardMinY = view.convert(keyboardFrame, from: nil).minY
        let contentMaxY = contentView.frame.maxY
        let extraSpacing:CGFloat = 18.0
        let overlap = max(0, contentMaxY + extraSpacing - keyboardMinY)
        animateContentCenterY(contentViewCenterY - overlap, notification: notification)
    }
    
    @objc private func keyboardWillHide(notification:Notification){
        guard isContentVisible else { return }
        animateContentCenterY(contentViewCenterY, notification: notification)
    }
    
    private func animateContentCenterY(_ centerY:CGFloat, notification:Notification){
        let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0.25
        let rawCurve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt ?? UInt(UIView.AnimationOptions.curveEaseInOut.rawValue)
        let options = UIView.AnimationOptions(rawValue: rawCurve << 16)
        UIView.animate(withDuration: duration, delay: 0, options: options) {[weak self] in
            self?.contentView.center.y = centerY
        }
    }
    
    private func contentShowAnimation()
    {
        isContentVisible = true
        UIView.animate(withDuration: 0.5, delay: 0) {[weak self] in
            guard let self else { return }
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.35)
            self.contentView.alpha = 1
            self.contentView.transform = CGAffineTransformIdentity
        }
    }
    
    private func contentClose(_ completion:(()->())? = nil){
        isContentVisible = false
        view.endEditing(true)
        UIView.animate(withDuration: 0.5, delay: 0) {[weak self] in
            guard let self else { return }
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0)
            self.contentView.alpha = 0
            self.contentView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.92, 0.92)
        }completion: { _ in
            self.dismiss(animated: false) {
                completion?()
            }
        }
    }



}

extension HKCFieldAlertController:UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
