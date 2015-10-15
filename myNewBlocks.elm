

import Debug
import Color exposing (..)
import Graphics.Element exposing (..)
import Graphics.Collage exposing (..)
import Graphics.Input exposing (customButton)
import Text exposing (fromString, typeface, style)
import Signal exposing (..)
import Maybe exposing (..)
import List exposing (length)
import Dict
import Window

-- my modules
import View exposing (..)
import Constants exposing (..)
import Model exposing (..)
import SignalProcessing exposing (..)
import BlockMenu exposing (menuButtons)


applyTypeface = typeface ["Courier New", "times new roman"]

dummyBlocksSmall2 = Dict.insert 2 (dummyMapAndRockBlock onlyFilterExp 2) (Dict.insert 1 (dummyMapAndRockBlock onlyMapExp 1) Dict.empty)

dummyModelSmall2 = {nextID = 4, blocks = dummyBlocksSmall2}


dummyBlocks = Dict.insert 4 (dummyMapAndRockBlock smallerExp 4) (Dict.insert 3 (dummyRockBlock 3) (Dict.insert 2 (dummyMapAndRockBlock smallExp 2) (Dict.insert 1 (dummyMapAndRockBlock bigExp 1) Dict.empty)))
dummyModel2 = {nextID = 5, blocks = dummyBlocks}

dummyModelSmall = {nextID = 3, blocks = dummyBlocksSmall2}

onlyFilterExp = H (Filter Nothing Nothing)

onlyMapExp = H (Map  Nothing Nothing)

smallerExp = H (Map  Nothing (Just (R dummyRockList)))

bigExp = H (Map Nothing (Just (Higher (Filter Nothing (Just (Higher (Map  Nothing Nothing )))))))

smallExp = H (Filter Nothing (Just (Higher (Map  Nothing (Just (R dummyRockList)) ))))

dummyMapAndRockBlock exp id = 
  let 
  (els, forms) = expToElsAndForms exp id
  in
      {id = id
      , ele = els
      , pos = (-(id*50), -(id*50))
      , exp = exp
      , forms = forms
      , selected = False}


dummyRockBlock id = 
  let (els, forms) = expToElsAndForms (RE (R  dummyRockList)) id
  in
      {id= id
          , ele = els
          , selected = False
          , pos= (0, 0)
          , exp = RE (R dummyRockList)
          , forms = forms
           }


dummyRockList : List Rock
dummyRockList = [
  {value= 0, solid= True, color = red}
  , {value = 1, solid = False, color = blue}
  , {value = 2, solid = False, color = purple}
  , {value = 3, solid = False, color = red}
  , {value = 4, solid = False, color = purple}
  , {value = 5, solid = True, color = blue}
  , {value = 6, solid = False, color = red}
  , {value = 7, solid = False, color = purple}
  , {value = 8, solid = True, color = red}]

--main = collage 700 700 (viewRocks (Just {pos= (-300, 300), rockList= dummyRockList} ))

helperCircles = List.map (\ p -> (move  p (filled green(circle 5.0)))) [(0.0, 0.0)
                                                                        , (-50.0, 0.0)
                                                                        , (50.0, 0.0)
                                                                        , (-100.0, 0.0)
                                                                        , (100.0, 0.0)
                                                                        , (-200.0, 0.0)
                                                                        , (200.0, 0.0)
                                                                        , (0.0, 100.0)
                                                                        , (0.0, -100.0)
                                                                        , (-300.0, 0.0)
              
                                                                        , (300, 0.0)]


centerBall = circle 10.0
              |> filled  purple
              |> move (0,0)

view : (Int, Int) -> Model -> Element
view (w, h) m =

  let blockList = Dict.values m.blocks
  in
      collage w h
      ( [centerBall] ++
        (displayForms blockList) ++ 
          (displayElements blockList) ++
         menuButtons
         )


displayElements : List Block -> List Form
displayElements blocks =
  List.concatMap (\b-> 
    List.map (\e ->  move (floatPos b.pos) e) b.ele) blocks


displayForms : List Block -> List Form
displayForms blocks = 
  List.concatMap (\b -> 
    List.map (\f -> move (floatPos b.pos) f) b.forms) blocks


main = Signal.map2 view Window.dimensions  foldModel

foldModel : Signal Model 
foldModel = Signal.foldp signalRouter dummyModelSmall2 allUpdateSignals

