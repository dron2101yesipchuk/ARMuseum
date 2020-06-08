//
//  ExhibitsManager.swift
//  ARMuseum
//
//  Created by Dron on 10.05.2020.
//  Copyright © 2020 dron. All rights reserved.
//

import UIKit

class ExhibitsManager {
    
    static let shared = ExhibitsManager()

    private var exhibits: [String:VirtualInfo] = [
        "f1InMonaco":VirtualInfo(name: "Monaco GP in 1983", text: "«Формула-1» (повна назва: «Чемпіонат світу ФІА» — англ. FIA Formula One World Championship) — чемпіонат світу з кільцевих автоперегонів на автомобілях з відкритими колесами, який відбувається під егідою Міжнародної Автомобільної Федерації (FIA)[1]. Перш за все «формула» — це термін, який визначає набір правил, які обов'язкові до виконання всіма учасниками перегонів. Чемпіонат світу у класі «Формула-1» відбувається щороку і складається з Гран-прі, або етапів, які проводяться на спеціально побудованих трасах, або підготовлених вулицях міста. Наприкінці сезону, за підсумками всіх гонок визначається переможець чемпіонату. У Формулі-1 змагаються як окремі пілоти, так і команди. Пілот-переможець отримує титул чемпіона світу, а команда-переможець отримує Кубок конструкторів. Результати кожної траси оцінюються за допомогою системи балів для визначення двох щорічних чемпіонатів світу, один для водіїв F1 і один для конструкторів F1. Автогонщики, конструктори команди, спортивні чиновники, організатори та схеми повинні бути володарями дійсних Супер Ліцензії, найвищого класу гоночних ліцензії, виданої FIA. Команди учасники змагань Формули-1 використовують гоночні автомобілі («боліди») власного виробництва. Тому для кожної команди вкрай важливо мати не лише швидкого і стабільного пілота та гарну стратегію, але й надзвичайно сильний конструкторський відділ. Наразі боліди Формули-1 розвивають швидкість до 360 км/год (хоча в останні роки FIA намагалась зменшити швидкість, впроваджуючи нові технічні правила), та здатні витримувати у поворотах перевантаження до 5 g. Кількість обертів двигуна обмежена до 15 000 об/хв[2]., проте слід зазначити, що за всі роки свого існування Формула-1 постійно змінювалася. Історично основним центром розвитку Формули-1 є Європа. Більшість баз та дослідницьких центрів команд розташовано на цьому континенті. Однак, сфера спорту значно розширилася в останні роки і дедалі більше число Гран-прі проводяться на інших континентах.", images: [UIImage(named: "f12020"), UIImage(named: "f11980"),  UIImage(named: "f12012")], audio: "Safety in F1", videoLink: "https://devstreaming-cdn.apple.com/videos/wwdc/2016/102w0bsn0ge83qfv7za/102/hls_vod_mvp.m3u8"),
        "restingMan":VirtualInfo(name: "Resting man", text: "Ферна́ндо Ало́нсо Ді́ас (ісп. Fernando Alonso Díaz, *29 липня 1981, Ов'єдо) — іспанський автогонщик, дворазовий чемпіон світу у класі Формула-1 — 2005 і 2006 років. У сезоні 2010 перейшов у команду Феррарі, а з 2015-го року повернувся до Mclaren.", images: [UIImage(named: "AlonsoInChair"), UIImage(named: "AlonsoInFerrari")], audio: nil, videoLink: nil)
    ]
    
    func findExhibitInfo(exhibitName: String) -> VirtualInfo? {
        let exhibit = exhibits[exhibitName]
        return exhibit
    }
    
}
