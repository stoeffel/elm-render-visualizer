-- Read more about this program in the official Elm guide:
-- https://guide.elm-lang.org/architecture/user_input/buttons.html


module Main exposing (..)

import Dict
import Html exposing (beginnerProgram, div, button, text, input)
import Html.Events exposing (onClick, onInput)
import Html.Attributes exposing (defaultValue, style)
import Debug.View


type Animal
    = Dog String Size
    | Bird


type Size
    = Small
    | Big


main =
    beginnerProgram
        { model =
            { counter = 0
            , by = 1
            , animals = [ Dog "doggy" Big, Bird, Bird, Bird, Bird, Bird, Bird, Bird ]
            , foo =
                { animals = [ Bird, Bird, Bird, Bird, Bird, Bird, Bird ]
                , bar = 4
                }
            , fn = toString
            , empty = []
            , tup = ( 1, 2, 3, 4, 5 )
            , d = Dict.fromList [ ( 1, "a" ), ( 2, "b" ) ]
            }
        , view = view
        , update = update
        }


view model =
    div
        [ style
            [ ( "margin", "auto" )
            , ( "width", "60%" )
            ]
        ]
        [ viewButton "-" Decrement
        , Debug.View.inspect viewCounter model
        , viewButton "+" Increment
        , Debug.View.inspect viewInput model.by
        , Debug.View.inspect viewInput 0
        ]


viewInput by =
    input [ onInput Change, defaultValue <| toString by ] []


viewCounter model =
    div [] [ text (toString model.counter) ]


viewButton label msg =
    button [ onClick msg ] [ text label ]


type Msg
    = Increment
    | Decrement
    | Change String


update msg model =
    case msg of
        Increment ->
            { model | counter = model.counter + model.by }

        Decrement ->
            { model | counter = model.counter - model.by }

        Change x ->
            let
                newBy =
                    String.toInt x
                        |> Result.withDefault model.by
            in
                { model | by = newBy }
