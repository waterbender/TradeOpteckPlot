//
//  PlotGraphsView.swift
//  TradeOpteck
//
//  Created by Yevgenii Pasko on 4/27/18.
//  Copyright © 2018 Yevgenii Pasko. All rights reserved.
//

import UIKit
import CorePlot

class PlotGraphsView: CPTGraphHostingView, CPTPlotDataSource, CPTScatterPlotDataSource, CPTAxisDelegate  {
    
    private var scatterGraph : CPTXYGraph? = nil
    var plotViewModel: PlotViewModel?
    
    func plotGraph() {
        
        makeObservable()
        self.perform(#selector(updateLogic))
//        let timer = Timer.scheduledTimer(timeInterval: 1.0,
//                                                           target: self,
//                                                           selector: #selector(updateLogic),
//                                                           userInfo: nil,
//                                                           repeats: true)
//        timer.fire()
    }
    
    @objc func updateLogic() {
        createBoundsAndGraph()
        plotViewModel?.compliteViewControllerHandler!()
        //configureAxes()
        self.scatterGraph?.reloadData()
    }
    
    func createBoundsAndGraph() {
        
        // Create graph from theme
        let newGraph = CPTXYGraph(frame: .zero)
        newGraph.apply(CPTTheme(named: .stocksTheme))
        
        let hostingView = self
        hostingView.hostedGraph = newGraph
        
        // Paddings
        newGraph.paddingLeft   = 0.0
        newGraph.paddingRight  = 0.0
        newGraph.paddingTop    = 0.0
        newGraph.paddingBottom = 0.0
        
        // Create a blue plot area
        let boundLinePlot = CPTScatterPlot(frame: .zero)
        let blueLineStyle = CPTMutableLineStyle()
        blueLineStyle.miterLimit    = 1.0
        blueLineStyle.lineWidth     = 3.0
        blueLineStyle.lineColor     = .blue()
        boundLinePlot.dataLineStyle = blueLineStyle
        boundLinePlot.identifier    = NSString.init(string: "Blue Plot")
        boundLinePlot.dataSource    = self
        newGraph.add(boundLinePlot)
        
        // Add plot symbols
        let symbolLineStyle = CPTMutableLineStyle()
        symbolLineStyle.lineColor = .black()
        let plotSymbol = CPTPlotSymbol.ellipse()
        plotSymbol.fill          = CPTFill(color: .blue())
        plotSymbol.lineStyle     = symbolLineStyle
        plotSymbol.size          = CGSize(width: 10.0, height: 10.0)
        boundLinePlot.plotSymbol = plotSymbol
        
        // Create a green plot area
        let dataSourceLinePlot = CPTScatterPlot(frame: .zero)
        let greenLineStyle               = CPTMutableLineStyle()
        greenLineStyle.lineWidth         = 3.0
        greenLineStyle.lineColor         = .green()
        greenLineStyle.dashPattern       = [5.0, 5.0]
        dataSourceLinePlot.dataLineStyle = greenLineStyle
        dataSourceLinePlot.identifier    = NSString.init(string: "Green Plot")
        dataSourceLinePlot.dataSource    = self
        
        // Put an area gradient under the plot above
        let areaColor    = CPTColor(componentRed: 0.3, green: 1.0, blue: 0.3, alpha: 0.8)
        let areaGradient = CPTGradient(beginning: areaColor, ending: .clear())
        areaGradient.angle = -90.0
        let areaGradientFill = CPTFill(gradient: areaGradient)
        dataSourceLinePlot.areaFill      = areaGradientFill
        dataSourceLinePlot.areaBaseValue = 1.75
        
        // Animate in the new plot, as an example
        dataSourceLinePlot.opacity = 0.0
        newGraph.add(dataSourceLinePlot)
        
        let fadeInAnimation = CABasicAnimation(keyPath: "opacity")
        fadeInAnimation.duration            = 1.0
        fadeInAnimation.isRemovedOnCompletion = false
        fadeInAnimation.fillMode            = kCAFillModeForwards
        fadeInAnimation.toValue             = 1.0
        dataSourceLinePlot.add(fadeInAnimation, forKey: "animateOpacity")
        
        self.scatterGraph = nil
        self.scatterGraph = newGraph
    }
    
    func makeObservable() {
        plotViewModel?.compliteViewControllerHandler =  {
            
            OperationQueue.main.addOperation({ [weak self] in
                
                let hostedGraph = self?.scatterGraph?.hostingView?.hostedGraph
                // Axes
                let axisSet = hostedGraph?.axisSet as! CPTXYAxisSet
                let objectInfo = self?.plotViewModel?.currentCurrencies.first as? CurrencyObject
                
                if let info = objectInfo {
                    
                    // Plot space
                    let plotSpace = hostedGraph?.defaultPlotSpace as! CPTXYPlotSpace
                    plotSpace.allowsUserInteraction = true
                    
                    let locy = info.minValue-info.minValue/5 as NSNumber
                    let lengthy = info.minValue/2.5 as NSNumber
                    let lengthx = (self?.plotViewModel?.currentCurrencies.count ?? 50) as NSNumber
                    plotSpace.yRange = CPTPlotRange(location:locy, length:lengthy)
                    plotSpace.xRange = CPTPlotRange(location:0.0, length:7)
                    
                    var axisLabels = Set<CPTAxisLabel>()
                    for (idx, currency) in (self?.plotViewModel?.currentCurrencies.enumerated())! {
                        
                        guard let currencyObject = currency as? CurrencyObject else {
                            return
                        }
                        
                        let style = CPTMutableTextStyle()
                        style.color = .white();
                        style.fontSize = 15;
                        style.textAlignment = .left
                        
                        let label:CPTAxisLabel?
                        
                        if ((idx % (self?.plotViewModel?.pointAxisValue)!) == 0) {
                            label = CPTAxisLabel(text: currencyObject.dateHours, textStyle: style)
                        } else {
                            label = CPTAxisLabel(text: "", textStyle: style)
                        }
                        
                        label?.tickLocation = NSNumber(value: idx)
                        label?.offset = 5
                        label?.alignment = .left
                        axisLabels.insert(label!)
                    }
                    //xAxis.majorTickLocations = majorTickLocations
                    axisSet.xAxis?.majorIntervalLength = (self?.plotViewModel?.pointAxisValue as NSNumber?) ?? 50//self?.plotViewModel?.pointAxisValue!! as NSNumber
                    axisSet.xAxis?.axisLabels = axisLabels
                    axisSet.xAxis?.orthogonalPosition = info.minValue-info.minValue/20 as NSNumber
                    axisSet.xAxis?.labelingPolicy = .none
                
                    
                    if let y = axisSet.yAxis
                        
                    {
                        y.majorIntervalLength   = (locy.cgFloatValue()/20) as NSNumber
                        y.orthogonalPosition    = 0
                        y.minorTicksPerInterval = UInt((info.minValue/5))
                        y.labelExclusionRanges  = [
                        ]
                        y.delegate = self
                        //y.relabel()
                    }
                }
                //self?.configureAxes()
                self?.scatterGraph?.reloadData()
                //self?.layoutSubviews()
            })
        }
    }
    
    
}

extension PlotGraphsView {
    // MARK: - Plot Data Source Methods
    func numberOfRecords(for plot: CPTPlot) -> UInt
    {
        let count = UInt(self.plotViewModel?.currentCurrencies.count ?? 0)
        return count
    }
    
    func number(for plot: CPTPlot, field: UInt, record: UInt) -> Any?
    {
        
        let plotField = CPTScatterPlotField(rawValue: Int(field))
        
        let infoObject = self.plotViewModel?.currentCurrencies[Int(record)] as! CurrencyObject
        
        if plotField == .X {
            let xValue = record// dict["createdAt"]
            return xValue
        } else {
            let yValue = infoObject.minValue//Double(dict["minValue"]!)! as NSNumber
            return yValue
        }
    }
    
    
//    func configureAxes() {
//
//        // 1 - Configure styles
//        let axisLineStyle = CPTMutableLineStyle()
//        axisLineStyle.lineWidth = 2.0
//        axisLineStyle.lineColor = CPTColor.black()
//
//        // 2 - Get the graph's axis set
//        let axisSetGeneral = self.hostedGraph?.axisSet
//        guard let axisSet = axisSetGeneral as? CPTXYAxisSet else {
//            return
//        }
//
//        /*// 3 - Configure the x-axis
//        if let xAxis = axisSet.xAxis {
//            var axisLabels = Set<CPTAxisLabel>()
//
//            guard let currencies = plotViewModel?.currentCurrencies else {
//                return
//            }
//            for (idx, currency) in currencies.enumerated() {
//
//                guard let currencyObject = currency as? CurrencyObject else {
//                    return
//                }
//
//                //majorTickLocations.insert(NSNumber(value: idx))
//
//                if ((idx % (self.plotViewModel?.pointAxisValue)!) == 0) {
//
//                    let style = CPTMutableTextStyle()
//                    style.color = .white();
//                    style.fontSize = 15;
//                    style.textAlignment = .left
//
//                    let label = CPTAxisLabel(text: currencyObject.createdAt, textStyle: style)
//                    label.tickLocation = NSNumber(value: idx)
//                    label.offset = 5
//                    label.alignment = .left
//                    axisLabels.insert(label)
//                }
//            }
//            //xAxis.majorTickLocations = majorTickLocations
//            xAxis.axisLabels = axisLabels
//        }*/
//
//        // 4 - Configure the y-axis
//        if let yAxis = axisSet.yAxis {
//            yAxis.labelingPolicy = .fixedInterval
//            yAxis.labelOffset = -10.0
//            yAxis.minorTicksPerInterval = 3
//            yAxis.majorTickLength = 30
//            let majorTickLineStyle = CPTMutableLineStyle()
//            majorTickLineStyle.lineColor = CPTColor.black().withAlphaComponent(0.1)
//            yAxis.majorTickLineStyle = majorTickLineStyle
//            yAxis.minorTickLength = 20
//            let minorTickLineStyle = CPTMutableLineStyle()
//            minorTickLineStyle.lineColor = CPTColor.black().withAlphaComponent(0.05)
//            yAxis.minorTickLineStyle = minorTickLineStyle
//            yAxis.axisLineStyle = axisLineStyle
//        }
//    }
}
