import QtQuick
import QtTest
import "../game/Autoplay.js" as Auto
import "../game/Rules.js" as Rules
import "../game/Progress.js" as Progress
import "../game/Scenery.js" as Scenery

TestCase {
    name: "AutoplayAndWeather"

    function test_idlePhaseOrderAndPerPhaseForecast() {
        const start=new Date(2026,10,19,12,0)
        const interval=600
        const names=["daytime","sunset","night","sunrise","daytime"]
        function forecast(seconds,minutes) {
            return Scenery.idleWeather(new Date(start.getTime()+seconds*1000),seconds,minutes)
        }
        for (let step=0;step<names.length;step++) {
            compare(forecast(step*interval).phase,names[step])
            compare(forecast(step*interval+15).weather,forecast(step*interval+590).weather)
        }
        compare(forecast(179,3).phase,"daytime")
        compare(forecast(180,3).phase,"sunset")
        fuzzyCompare(forecast(90,3).solarTime,120,1e-5)
        let clear=0, prior=""
        for (let i=0;i<1000;i++) {
            const event=forecast(i*interval).weather
            if (event==="clear") clear++
            else verify(event!==prior)
            prior=event
        }
        verify(clear>=265 && clear<=335,"Clear weather count was "+clear)
    }

    function test_waveLimitUsesClearsAndCapsAt90() {
        compare(Auto.waveLimit({bestWave:80},{}),0)
        compare(Auto.waveLimit({bestTimedWave:14},{}),14)
        compare(Auto.waveLimit({}, {last:{wave:51,cleared:1,reason:"death",eligible:true}}),50)
        compare(Auto.waveLimit({}, {last:{wave:90,cleared:40,reason:"death",eligible:false}}),0)
        compare(Auto.waveLimit({}, {last:{wave:51,cleared:6,reason:"retired",eligible:true,stats:{clearedWave:50}}}),50)
        compare(Auto.waveLimit({bestClearedWave:110},{}),90)
        compare(Progress.merge({bestClearedWave:25},{bestClearedWave:12}).bestClearedWave,25)
        const run=Rules.create(23)
        Rules.startWave(run)
        Rules.finishWave(run)
        compare(run.metrics.bestClearedWave,1)
    }

    function test_randomSelectionSpendsOnlyAvailableGold() {
        const run=Rules.create(25)
        run.phase="reward"
        run.health=100
        run.offers=[{id:"dressing",category:"Supply"}]
        verify(Auto.select(run))
        compare(run.health,140)
        compare(run.phase,"between")

        Rules.openShop(run)
        run.shopStock=[{id:"restore",action:"supply",cost:433,sold:false}]
        run.gold=480
        verify(Auto.select(run))
        compare(run.gold,47)
        verify(run.shopStock[0].sold)
        run.shopStock.push({id:"cartridges",action:"supply",cost:20,sold:false})
        verify(Auto.select(run,true))
        compare(run.gold,47)
        compare(run.phase,"between")

        Rules.openShop(run)
        run.shopStock=[{id:"restore",action:"supply",cost:450,sold:false}]
        verify(Auto.select(run))
        compare(run.gold,47)
        compare(run.phase,"between")
    }

    function test_takeoverNavigatesAndKeepsTrueWeather() {
        const run=Rules.create(27)
        Rules.startWave(run)
        run.weatherEffect="incursion"
        compare(Auto.plan(run).direction,"down")
        Rules.lookFront(run,"down")
        const distant=Rules.spawn(run,{type:"silophosus",front:"left",lane:0})
        distant.warp=0
        verify(Auto.plan(run).seal)
        verify(!Auto.plan(run).direction)
        for (let i=0; i<2400 && Rules.takeoverActive(run); ++i)
            Rules.update(run,1/60,Auto.plan(run).seal,false)
        verify(run.abyssSeal.closed)
        compare(Scenery.roomWeather("night","down"),"clear")
        compare(Scenery.roomWeather("bloodMoon","down"),"clear")
        compare(Scenery.roomWeather("thunder","down"),"thunder")
        compare(Scenery.roomWeather("meteor","down"),"meteor")
    }
}
