//
//  ViewController.swift
//  Currency
//
//  Created by Sean Kearney on 01/11/2017.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    
    //MARK Model holders
    var currencyDict:Dictionary = [String:Currency]()
    var currencyArray = [Currency]()
    var baseCurrency:Currency = Currency.init(name:"EUR", rate:1, flag:"🇪🇺", symbol:"€")!
    var lastUpdatedDate:Date = Date()
    
    var convertValue:Double = 0
    
    var task: URLSessionDataTask?
    let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    //MARK Outlets

    @IBOutlet weak var baseSymbol: UILabel!
    @IBOutlet weak var baseTextField: UITextField!
    @IBOutlet weak var baseFlag: UILabel!
    @IBOutlet weak var lastUpdatedDateLabel: UILabel!
    
    @IBOutlet weak var gbpSymbolLabel: UILabel!
    @IBOutlet weak var gbpValueLabel: UILabel!
    @IBOutlet weak var gbpFlagLabel: UILabel!
    
    @IBOutlet weak var usdSymbolLabel: UILabel!
    @IBOutlet weak var usdValueLabel: UILabel!
    @IBOutlet weak var usdFlagLabel: UILabel!
    
    @IBOutlet weak var audSymbolLabel: UILabel!
    @IBOutlet weak var audValueLabel: UILabel!
    @IBOutlet weak var audFlagLabel: UILabel!
    
    @IBOutlet weak var cadSymbolLabel: UILabel!
    @IBOutlet weak var cadValueLabel: UILabel!
    @IBOutlet weak var cadFlagLabel: UILabel!
    
    @IBOutlet weak var czkSymbolLabel: UILabel!
    @IBOutlet weak var czkValueLabel: UILabel!
    @IBOutlet weak var czkFlagLabel: UILabel!
    
    @IBOutlet weak var jpySymbolLabel: UILabel!
    @IBOutlet weak var jpyValueLabel: UILabel!
    @IBOutlet weak var jpyFlagLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //add done button to keyboard
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.finishEditing))
        keyboardToolbar.setItems([doneButton], animated: true)
        baseTextField.inputAccessoryView = keyboardToolbar
        
        // create currency dictionary
        self.createCurrencyDictionary()
        
        // get latest currency values
        getConversionTable()
        convertValue = 1
        
        // set up base currency screen items
        baseTextField.text = String(format: "%.02f", baseCurrency.rate)
        baseSymbol.text = baseCurrency.symbol
        baseFlag.text = baseCurrency.flag
        
        // set up last updated date
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "dd/MM/yyyy hh:mm a"
        lastUpdatedDateLabel.text = dateformatter.string(from: lastUpdatedDate)
        
        // display currency info
        self.displayCurrencyInfo()
        
        
        // setup view mover
        baseTextField.delegate = self
        
        self.convert(self)
    }
    

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createCurrencyDictionary(){
        currencyDict["GBP"] = Currency(name:"GBP", rate:1, flag:"🇬🇧", symbol: "£")
        currencyDict["USD"] = Currency(name:"USD", rate:1, flag:"🇺🇸", symbol: "$")
        currencyDict["AUD"] = Currency(name:"AUD", rate:1, flag:"🇦🇺", symbol: "$")
        currencyDict["CAD"] = Currency(name:"CAD", rate:1, flag:"🇨🇦", symbol: "$")
        currencyDict["CZK"] = Currency(name:"CZK", rate:1, flag:"🇨🇿", symbol: "Kč")
        currencyDict["JPY"] = Currency(name:"JPY", rate:1, flag:"🇯🇵", symbol: "¥")
    }
    
    func displayCurrencyInfo() {
        // GBP
        if let c = currencyDict["GBP"]{
            gbpSymbolLabel.text = c.symbol
            gbpValueLabel.text = String(format: "%.02f", c.rate)
            gbpFlagLabel.text = c.flag
        }
        if let c = currencyDict["USD"]{
            usdSymbolLabel.text = c.symbol
            usdValueLabel.text = String(format: "%.02f", c.rate)
            usdFlagLabel.text = c.flag
        }
        if let c = currencyDict["AUD"]{
            audSymbolLabel.text = c.symbol
            audValueLabel.text = String(format: "%.02f", c.rate)
            audFlagLabel.text = c.flag
        }
        if let c = currencyDict["CAD"]{
            cadSymbolLabel.text = c.symbol
            cadValueLabel.text = String(format: "%.02f", c.rate)
            cadFlagLabel.text = c.flag
        }
        if let c = currencyDict["CZK"]{
            czkSymbolLabel.text = c.symbol
            czkValueLabel.text = String(format: "%.02f", c.rate)
            czkFlagLabel.text = c.flag
        }
        if let c = currencyDict["JPY"]{
            jpySymbolLabel.text = c.symbol
            jpyValueLabel.text = String(format: "%.02f", c.rate)
            jpyFlagLabel.text = c.flag
        }
    }
    
    
    func getConversionTable() {
        let urlStr:String = "https://api.fixer.io/latest"
        
        var request = URLRequest(url: URL(string: urlStr)!)
        request.httpMethod = "GET"
        
        task?.cancel()
        
        task = URLSession.shared.dataTask(with: request) {data, response, error in
            if error == nil{
                //print(response!)
                
                do {
                    let jsonDict = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String:Any]
                    //print(jsonDict)
                    
                    
                    DispatchQueue.main.async {
                        
                        self.indicator.center = self.view.center
                        self.view.addSubview(self.indicator)
                        self.indicator.startAnimating()
                        
                    }
                    if let ratesData = jsonDict["rates"] as? NSDictionary {
                        
                        
                        
                        //print(ratesData)
                        for rate in ratesData{
                            //print("#####")
                            let name = String(describing: rate.key)
                            let rate = (rate.value as? NSNumber)?.doubleValue
                            //var symbol:String
                            //var flag:String

                            
                            switch(name){
                            case "USD":
                                let c:Currency  = self.currencyDict["USD"]!
                                c.rate = rate!
                                self.currencyDict["USD"] = c
                            case "GBP":
                                let c:Currency  = self.currencyDict["GBP"]!
                                c.rate = rate!
                                self.currencyDict["GBP"] = c
                            case "AUD":
                                let c:Currency  = self.currencyDict["AUD"]!
                                c.rate = rate!
                                self.currencyDict["AUD"] = c
                            case "CAD":
                                let c:Currency  = self.currencyDict["CAD"]!
                                c.rate = rate!
                                self.currencyDict["CAD"] = c
                            case "CZK":
                                let c:Currency  = self.currencyDict["CZK"]!
                                c.rate = rate!
                                self.currencyDict["CZK"] = c
                            case "JPY":
                                let c:Currency  = self.currencyDict["JPY"]!
                                c.rate = rate!
                                self.currencyDict["JPY"] = c
                            default:
                                print("Ignoring currency: \(String(describing: rate))")
                            }
                            
                            self.lastUpdatedDate = Date()
                            DispatchQueue.main.async {
                                
                                self.indicator.stopAnimating()
                                
                                let dateformatter = DateFormatter()
                                dateformatter.dateFormat = "dd/MM/yyyy hh:mm a"
                                self.lastUpdatedDateLabel.text = dateformatter.string(from: self.lastUpdatedDate)
                                
                            }
                        }
                        
                    }
                }
                catch let error as NSError{
                    print(error)
                }
            }
            else{
                print("Error")
            }
            
        }
        task?.resume()
        
    }
    
    @IBAction func convert(_ sender: Any) {
        var resultGBP = 0.0
        var resultUSD = 0.0
        var resultAUD = 0.0
        var resultCAD = 0.0
        var resultCZK = 0.0
        var resultJPY = 0.0
        
        if let euro = Double(baseTextField.text!) {
            convertValue = euro
            if let gbp = self.currencyDict["GBP"] {
                resultGBP = convertValue * gbp.rate
            }
            if let usd = self.currencyDict["USD"] {
                resultUSD = convertValue * usd.rate
            }
            if let aud = self.currencyDict["AUD"] {
                resultAUD = convertValue * aud.rate
            }
            if let cad = self.currencyDict["CAD"] {
                resultCAD = convertValue * cad.rate
            }
            if let czk = self.currencyDict["CZK"] {
                resultCZK = convertValue * czk.rate
            }
            if let jpy = self.currencyDict["JPY"] {
                resultJPY = convertValue * jpy.rate
            }
        }

        gbpValueLabel.text = String(format: "%.02f", resultGBP)
        usdValueLabel.text = String(format: "%.02f", resultUSD)
        audValueLabel.text = String(format: "%.02f", resultAUD)
        cadValueLabel.text = String(format: "%.02f", resultCAD)
        czkValueLabel.text = String(format: "%.02f", resultCZK)
        jpyValueLabel.text = String(format: "%.02f", resultJPY)
    }
    
    @IBAction func refresh(_ sender: Any) {
        getConversionTable()
        
    }
    
    @objc func finishEditing(){
        view.endEditing(true)
    }
}

