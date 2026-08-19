//
//  HKCAlertController
    

import UIKit

enum HKCAlertActionType {
    case defaultAction
    case cancelAction
    case destructiveAction
}

class HKCAlertAction{
    var title:String?
    var type:HKCAlertActionType = .defaultAction
    var callBackClosure:(()->())?
    
    init(_ title: String? = nil, _ type: HKCAlertActionType, _ callBackClosure: (() -> Void)? = nil) {
        self.title = title
        self.type = type
        self.callBackClosure = callBackClosure
    }
}

class  HKCAlertViewModel{
    
    var contentBgColor:UIColor = UIColor.black
    var contentShadowColor:UIColor = UIColor.white
    var defaultActionBgColor:UIColor = UIColor.white
    var cancelActionBgColor:UIColor = UIColor(red: 223.0/255.0, green: 223.0/255.0, blue: 223.0/255.0, alpha: 1)
    var destructiveActionBgColor:UIColor = UIColor.red
    
    var defaultActionTintColor:UIColor = UIColor.black
    var cancelActionTintColor:UIColor = UIColor(red: 43.0/255.0, green: 43.0/255.0, blue: 43.0/255.0, alpha: 1)
    var destructiveActionTintColor:UIColor = UIColor.black
    
    var defaultActionBoardColor:UIColor?
    var cancelActionBoardColor:UIColor?
    var destructiveActionBoardColor:UIColor?
    
    
    var actionViewCorner:CGFloat = 20.0
    var contentCornerRadius:CGFloat = 34.0
    var actionTitleFont:UIFont = UIFont.systemFont(ofSize: 16.0, weight: .medium)
    
    var titleFont:UIFont = UIFont.systemFont(ofSize: 15.0, weight: .medium)
    var titleColor:UIColor = UIColor.white
    var messageFont:UIFont = UIFont.systemFont(ofSize: 14.0, weight: .regular)
    var messageColor:UIColor = UIColor.white.withAlphaComponent(0.8)
    
    init(){
        
    }
}

class HKCAlertActionButton:UIButton
{
    
    init(_ alertAction: HKCAlertAction? = nil,_ alertViewModel: HKCAlertViewModel? = nil) {
        self.alertAction = alertAction
        self.alertViewModel = alertViewModel
        super.init(frame: .zero)
        configure()
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    var alertAction:HKCAlertAction?{
        didSet{
            configure()
        }
    }
    var alertViewModel:HKCAlertViewModel?{
        didSet{
            configure()
        }
    }
    
    override var isHighlighted: Bool{
        didSet{
            alpha = isHighlighted ? 0.75 : 1.0
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = min(bounds.height * 0.5, alertViewModel?.actionViewCorner ?? 0)
    }
    
    private func configure() {
        guard let alertViewModel else { return }
        
        setTitle(alertAction?.title, for: .normal)
        titleLabel?.font = alertViewModel.actionTitleFont
        layer.masksToBounds = true
        
        
        switch alertAction?.type {
        case .cancelAction:
            backgroundColor = alertViewModel.cancelActionBgColor
            setTitleColor(alertViewModel.cancelActionTintColor, for: .normal)
            if alertViewModel.cancelActionBoardColor != nil {
                layer.borderColor = alertViewModel.cancelActionBoardColor!.cgColor
                layer.borderWidth = 1.3
            }
            
        case .destructiveAction:
            backgroundColor = alertViewModel.destructiveActionBgColor
            setTitleColor(alertViewModel.destructiveActionTintColor, for: .normal)
            if alertViewModel.destructiveActionBoardColor != nil {
                layer.borderColor = alertViewModel.destructiveActionBoardColor!.cgColor
                layer.borderWidth = 1.3
            }
        case .defaultAction, .none:
            backgroundColor = alertViewModel.defaultActionBgColor
            setTitleColor(alertViewModel.defaultActionTintColor, for: .normal)
            if alertViewModel.defaultActionBoardColor != nil {
                layer.borderColor = alertViewModel.defaultActionBoardColor!.cgColor
                layer.borderWidth = 1.3
            }
        }
    }
}


class HKCSheetAlertController: UIViewController, UIGestureRecognizerDelegate {
    var contentView:UIView = UIView()
    var alertViewModel:HKCAlertViewModel = HKCAlertViewModel()
    var contentViewHeight:CGFloat = 260.0
    var contentTitle:String?
    var contentMesssage:String?
    var actions:[HKCAlertAction] = []
    var titleLabel:UILabel?
    var messageLabel:UILabel?
    private var actionButtons:[HKCAlertActionButton] = []
    private var isContentVisible = false
    

    override func viewDidLoad()
    {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0)
        setupContentView()
        
        view.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapNullAreaViewGesture))
        tap.delegate = self
        view.addGestureRecognizer(tap)
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
    
    private func setupContentView(){
        contentView.frame = CGRectMake(0, view.bounds.height, view.bounds.width, contentViewHeight)
        contentView.backgroundColor = alertViewModel.contentBgColor
        contentView.layer.cornerRadius = alertViewModel.contentCornerRadius
        contentView.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner];
        contentView.layer.masksToBounds = false
        contentView.layer.shadowColor = alertViewModel.contentShadowColor.withAlphaComponent(0.5).cgColor
        contentView.layer.shadowRadius = 4.0
        contentView.layer.shadowOffset = CGSizeMake(0, -3.0)
        contentView.layer.shadowOpacity = 1
        view.addSubview(contentView)
        if contentTitle != nil && contentTitle!.count > 0
        {
            setUpTitleLabel()
        }
        
        if contentMesssage != nil && contentMesssage!.count > 0{
            setUpMessageLabel()
        }
        
        for action in actions {
            addActionButton(action)
        }
    }
    
    private func setUpTitleLabel(){
        titleLabel = UILabel()
        titleLabel!.font = alertViewModel.titleFont
        titleLabel!.textColor = alertViewModel.titleColor
        titleLabel!.text = contentTitle
        titleLabel!.textAlignment = .center
        titleLabel!.numberOfLines = 0
        contentView.addSubview(titleLabel!)
    }
    
    private func setUpMessageLabel(){
        messageLabel = UILabel()
        messageLabel!.font = alertViewModel.messageFont
        messageLabel!.textColor = alertViewModel.messageColor
        messageLabel!.text = contentMesssage
        messageLabel!.textAlignment = .center
        messageLabel!.numberOfLines = 0
        contentView.addSubview(messageLabel!)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        caculateContentHeight()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        contentShowAnimation()
    }
    
    class func alertControllerWithTitleAndMessage(title:String? = nil,
                                                  message:String? = nil,
                                                  alertViewModel:HKCAlertViewModel = HKCAlertViewModel()) -> HKCSheetAlertController {
        let alertController = HKCSheetAlertController()
        alertController.contentTitle = title
        alertController.contentMesssage = message
        alertController.alertViewModel = alertViewModel
        alertController.modalPresentationStyle = .overFullScreen
        alertController.modalTransitionStyle = .crossDissolve
        return alertController
    }
    
    public func addAction(title:String,type:HKCAlertActionType,callBackClosure:(()->())? = nil){
        let action = HKCAlertAction(title, type, callBackClosure)
        actions.append(action)
        
        if isViewLoaded {
            addActionButton(action)
            view.setNeedsLayout()
        }
    }
    
    private func addActionButton(_ action:HKCAlertAction) {
        let actionButton = HKCAlertActionButton(action, alertViewModel)
        actionButton.addTarget(self, action: #selector(clickActionButton(sender:)), for: .touchUpInside)
        contentView.addSubview(actionButton)
        actionButtons.append(actionButton)
    }
    
    @objc private func clickActionButton(sender:HKCAlertActionButton){
        let callBackClosure = sender.alertAction?.callBackClosure
        contentClose {
            callBackClosure?()
        }
    }
    
    private func caculateContentHeight(){
        
        let contentWidth = view.bounds.size.width
        guard contentWidth > 0 else { return }
        let horizontalMargin:CGFloat = 20.0
        let actionHeight:CGFloat = 52.0
        let actionSpacing:CGFloat = 12.0
        let bottomPadding = max(view.safeAreaInsets.bottom, 12.0) + 8.0
        var beginOriginY = 20.0
        
        if titleLabel != nil {
            let maxTitleWidth = contentWidth * 0.6
            let titleSize = titleLabel!.sizeThatFits(CGSizeMake(maxTitleWidth, CGFloat(MAXFLOAT)))
            let titleWidth = min(ceil(titleSize.width), maxTitleWidth)
            titleLabel!.frame = CGRectMake((contentWidth - titleWidth) * 0.5,
                                           beginOriginY,
                                           titleWidth,
                                           ceil(titleSize.height))
            beginOriginY = CGRectGetMaxY(titleLabel!.frame) + 16.0
        }
        
        if messageLabel != nil {
            let maxMessageWidth = contentWidth * 0.8
            let messageSize =  messageLabel!.sizeThatFits(CGSizeMake(maxMessageWidth, CGFloat(MAXFLOAT)))
            let messageWidth = min(ceil(messageSize.width), maxMessageWidth)
            messageLabel!.frame = CGRectMake((contentWidth - messageWidth) * 0.5,
                                             beginOriginY,
                                             messageWidth,
                                             ceil(messageSize.height))
            beginOriginY = CGRectGetMaxY(messageLabel!.frame) + 24.0
        }
        
        if actionButtons.count > 0 && titleLabel == nil && messageLabel == nil {
            beginOriginY = 24.0
        }
        
        for actionButton in actionButtons
        {
            actionButton.frame = CGRectMake(horizontalMargin,
                                            beginOriginY,
                                            contentWidth - horizontalMargin * 2.0,
                                            actionHeight)
            beginOriginY = CGRectGetMaxY(actionButton.frame) + actionSpacing
        }
        
        if actionButtons.count > 0 {
            beginOriginY -= actionSpacing
        }
        
        contentViewHeight = max(beginOriginY + bottomPadding, 120.0 + view.safeAreaInsets.bottom)
        let contentOriginY = isContentVisible ? view.bounds.height - contentViewHeight : view.bounds.height
        contentView.frame = CGRectMake(0, contentOriginY, contentWidth, contentViewHeight)
        
    }
    private func contentShowAnimation()
    {
        isContentVisible = true
        UIView.animate(withDuration: 0.5, delay: 0) {[weak self] in
            guard let self else { return }
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.35)
            self.contentView.frame = CGRectMake(0, self.view.bounds.height - self.contentViewHeight, self.view.bounds.width, self.contentViewHeight)
        }
    }
    
    private func contentClose(_ completion:(()->())? = nil){
        isContentVisible = false
        UIView.animate(withDuration: 0.5, delay: 0) {[weak self] in
            guard let self else { return }
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0)
            self.contentView.frame = CGRectMake(0, self.view.bounds.height, self.view.bounds.width, self.contentViewHeight)
        }completion: { _ in
            self.dismiss(animated: false) {
                completion?()
            }
        }
    }

}
