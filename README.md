# CurrencyConverter
Simple Currency converter app written in Swift

 <img width="1237" alt="Screen Shot 2022-10-10 at 6 03 59 PM" src="https://user-images.githubusercontent.com/8087709/194842180-b2da7ea3-0a3d-484c-9d95-6465ad76cb20.png">

# Information 

Language & Envinronment: 
---
- Swift 5 & Xcode 14.0
---
Total Hours: 
- Estimated 16 hours in 3days
---
3rd Party Library used: 
---
- Snapkit using PCM : Since I didn't use NIB and Storyboard, this library helps me to layout the UI quicker.
---
Architecture
---
- Ive used Model-View-ViewModel(MVVM) for the architecture. You can also see some patterns like direct injection(DI), factory, delegation, decorators. 
- I applied single responsibility principle which can be helpful for Unit Testing.
---
Details
---
- Currencies are fetch from json file _wallet.json_. This includes $1,000 initial user balance. 
- Adding currencies should be easy, just add it to the json with correct data specially the currency field.
- Rules are applied and fetch also from json file _comission_rule.json_. Rules that is implemented are 
  - 5 Free tansaction 
  - 200 EUR minimum is free transaction
  - 10 intervals is free transaction
- Didn't add data persistency since the data always come from json every time the app launches
- UI/UX isn't the best, but I tried :D 

![screenshots](https://user-images.githubusercontent.com/8087709/194843096-8007a7de-1935-468e-b690-ba7ec7662092.png)

