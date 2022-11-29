//
//  Color+Extension.swift
//  TaskDo
//
//  Created by Philippe Yong on 23/01/2021.
//

import SwiftUI

extension Color {

    static let themeOrange = Color(#colorLiteral(red: 1, green: 0.592467308, blue: 0, alpha: 1))
    static let themeBlue = Color(#colorLiteral(red: 0.3133157194, green: 0.4862174392, blue: 0.7320785522, alpha: 1))
    static let primaryColor = Color("primaryColor")
    static let primaryColor2 = Color("primaryColor2")
    static let primaryColor3 = Color("primaryColor3")
    
    
    static let viewColor = Color("viewColor")
    static let textColor = Color("textColor")
    static let darkSelectedTextColor = Color(#colorLiteral(red: 0.3647058824, green: 0.3647058824, blue: 0.3647058824, alpha: 1))
    static let lineColor = Color("lineColor")
    static let smallRoundCornerBtnColor = Color("smallRoundCornerBtnColor")
    static let halfModalViewColor = Color("halfModalViewColor")

    static let taskColors: [Color] =
        [Color.primaryColor2.opacity(0.95), Color(#colorLiteral(red: 1, green: 0.592467308, blue: 0, alpha: 1)), Color(#colorLiteral(red: 1, green: 0.8431372549, blue: 0.2901960784, alpha: 1)), Color(#colorLiteral(red: 1, green: 0.5137254902, blue: 0.5137254902, alpha: 1)),
         Color(#colorLiteral(red: 1, green: 0.5921568627, blue: 0.8352941176, alpha: 1)), Color(#colorLiteral(red: 0.6862745098, green: 0.9529411765, blue: 0.6431372549, alpha: 1)), Color(#colorLiteral(red: 0.5921568627, green: 0.9254901961, blue: 1, alpha: 1)), Color(#colorLiteral(red: 0.5921568627, green: 0.7568627451, blue: 1, alpha: 1)),
         Color.textColor
        ]
    
    static let taskColorsUI: [UIColor] =
        [#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1), #colorLiteral(red: 1, green: 0.592467308, blue: 0, alpha: 1), #colorLiteral(red: 1, green: 0.8431372549, blue: 0.2901960784, alpha: 1), #colorLiteral(red: 1, green: 0.5137254902, blue: 0.5137254902, alpha: 1),
         #colorLiteral(red: 1, green: 0.5921568627, blue: 0.8352941176, alpha: 1), #colorLiteral(red: 0.6862745098, green: 0.9529411765, blue: 0.6431372549, alpha: 1), #colorLiteral(red: 0.5921568627, green: 0.9254901961, blue: 1, alpha: 1), #colorLiteral(red: 0.5921568627, green: 0.7568627451, blue: 1, alpha: 1)
        ]

    
    
    static let  premiumViewColor = Color(#colorLiteral(red: 1, green: 0.8392156863, blue: 0.4235294118, alpha: 1))
    static let premiumTitleColor = Color(#colorLiteral(red: 0.5490196078, green: 0.4039215686, blue: 0.1176470588, alpha: 1))
    
    static let taskCompletedColor = Color(#colorLiteral(red: 0.337254902, green: 0.9647058824, blue: 0.3254901961, alpha: 1))
    static let smallGrayButtonColor = Color(#colorLiteral(red: 0.8745098039, green: 0.8745098039, blue: 0.8745098039, alpha: 1))
    static let percentColor = Color("percentColor")
    
    static let smallButtonColor = Color("smallButtonColor")
    
    static let tickColor = Color("tickColor")
    static let timerColor = Color("timerColor")
}



//  #colorLiteral(red: 0.9579587579, green: 0.7194670439, blue: 0.2015263736, alpha: 1), #colorLiteral(red: 0.4364182949, green: 0.6582637429, blue: 0.8597204089, alpha: 1), #colorLiteral(red: 0.2980392157, green: 0.9215686275, blue: 0.7725490196, alpha: 1), #colorLiteral(red: 1, green: 0.4784313725, blue: 0.4784313725, alpha: 1),
//#colorLiteral(red: 0.9725490196, green: 0.8549019608, blue: 0.2392156863, alpha: 1), #colorLiteral(red: 0.5647058824, green: 0.9176470588, blue: 0.4431372549, alpha: 1), #colorLiteral(red: 0.7254901961, green: 0.6274509804, blue: 1, alpha: 1), #colorLiteral(red: 0.6294775009, green: 0.8249928355, blue: 0.8545476794, alpha: 1),


/*
 [Color(#colorLiteral(red: 0.9764705882, green: 0.5333333333, blue: 0.4, alpha: 1)), Color(#colorLiteral(red: 1, green: 0.2588235294, blue: 0.05490196078, alpha: 1)), Color(#colorLiteral(red: 0.5019607843, green: 0.7411764706, blue: 0.6196078431, alpha: 1)), Color(#colorLiteral(red: 0.537254902, green: 0.8549019608, blue: 0.3490196078, alpha: 1)),
  Color(#colorLiteral(red: 0.2156862745, green: 0.368627451, blue: 0.5921568627, alpha: 1)), Color(#colorLiteral(red: 0.9843137255, green: 0.3960784314, blue: 0.2588235294, alpha: 1)), Color(#colorLiteral(red: 1, green: 0.7333333333, blue: 0, alpha: 1)), Color(#colorLiteral(red: 0.2470588235, green: 0.4078431373, blue: 0.1098039216, alpha: 1)),
  Color(#colorLiteral(red: 0.5647058824, green: 0.6862745098, blue: 0.7725490196, alpha: 1)), Color(#colorLiteral(red: 0.2, green: 0.4196078431, blue: 0.5294117647, alpha: 1)), Color(#colorLiteral(red: 0.1843137255, green: 0.1843137255, blue: 0.1843137255, alpha: 1)), Color(#colorLiteral(red: 0.462745098, green: 0.2117647059, blue: 0.1490196078, alpha: 1)),
  Color(#colorLiteral(red: 0, green: 0.231372549, blue: 0.2745098039, alpha: 1)), Color(#colorLiteral(red: 0.02745098039, green: 0.3411764706, blue: 0.3568627451, alpha: 1)), Color(#colorLiteral(red: 0.4, green: 0.6470588235, blue: 0.6784313725, alpha: 1)), Color(#colorLiteral(red: 0.768627451, green: 0.8745098039, blue: 0.9019607843, alpha: 1)),
  Color.textColor, Color(#colorLiteral(red: 1, green: 0.592467308, blue: 0, alpha: 1))
 ]
 */
