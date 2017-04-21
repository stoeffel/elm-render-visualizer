module Debug.View exposing (inspect, inspect2)

import Native.Debug.View
import Html exposing (Html)
import Html.Attributes exposing (style, id, attribute, property, class)


inspect : String -> (a -> Html msg) -> a -> Html msg
inspect identifier view x =
    contentSpan
        (view x
            :: (wrapper identifier <|
                    Native.Debug.inspect x identifier
               )
        )


inspect2 : String -> (a -> b -> Html msg) -> a -> b -> Html msg
inspect2 identifier view x y =
    contentSpan
        (view x y
            :: (wrapper identifier <|
                    Native.Debug.inspect2 x y identifier
               )
        )


stylesheet : Html msg
stylesheet =
    Html.node "style"
        []
        [ Html.text css
        ]


css : String
css =
    """
    .elm-render-visualizer-indent-block {
        padding-left: 2em;
    }

    .elm-render-visualizer-collapsed {
        display: flex;
    }
    .elm-render-visualizer-collapsed .elm-render-visualizer-indent-block {
        display: flex;
        padding-left: 0px;
    }
    .elm-render-visualizer-collapsed .elm-render-visualizer-indent-block:first-child {
        padding-left: 10px;
    }

    .elm-render-visualizer-collapsed .elm-render-visualizer-flex {
        display: flex;
        white-space: nowrap;
    }

    .elm-render-visualizer-collapsed span {
        white-space: nowrap;
    }
"""


contentSpan : List (Html msg) -> Html msg
contentSpan content =
    Html.span
        [ style
            [ ( "position", "relative" )
            ]
        ]
        (stylesheet :: content)


styles { radius, border, inverse } =
    [ ( "position", "absolute" )
    , ( "margin-top", "-10px" )
    , ( "left", "-4px" )
    , ( "background-color"
      , if inverse then
            "#c7f465"
        else
            "rgb(85, 99, 102)"
      )
    , ( "color"
      , if inverse then
            "rgb(85, 99, 102)"
        else
            "#fefefe"
      )
    , ( "max-height", "400px" )
    , ( "border-color", "#c7f465" )
    , ( "border-width", "2px" )
    , ( "border-style", border )
    , ( "box-shadow", "0 1px 3px rgba(85, 99, 102, 0.12), 0 1px 2px rgba(85, 99, 102, 0.24)" )
    , ( "border-radius", radius )
    ]


wrapper : String -> List ElmType -> List (Html msg)
wrapper identifier history =
    [ counter identifier <| List.length history
    , entries identifier history
    ]


entries : String -> List ElmType -> Html msg
entries identifier history =
    Html.div
        [ style <|
            [ ( "display", "none" )
            , ( "padding", "10px" )
            , ( "z-index", "30000" )
            , ( "font-family", "monospace" )
            ]
                ++ styles { radius = "5px", border = "solid", inverse = False }
        , id ("elm-render-visualizer-entry-" ++ identifier)
        ]
        [ closeButton identifier
        , List.indexedMap (entry identifier) history
            |> List.reverse
            |> Html.div
                [ style
                    [ ( "overflow", "scroll" )
                    , ( "width", "100%" )
                    ]
                ]
        ]


closeButton : String -> Html msg
closeButton identifier =
    Html.button
        [ style <|
            [ ( "display", "none" )
            , ( "padding", "10px" )
            , ( "position", "absolute" )
            , ( "padding", "10px" )
            , ( "background-color", "rgb(199, 244, 101)" )
            , ( "color", "rgb(85, 99, 102)" )
            , ( "max-height", "400px" )
            , ( "border-color", "rgb(199, 244, 101)" )
            , ( "border-width", "2px" )
            , ( "border-style", "none" )
            , ( "border-bottom-left-radius", "50%" )
            , ( "width", "20px" )
            , ( "height", "20px" )
            , ( "display", "block" )
            , ( "z-index", "99999999" )
            , ( "position", "absolute" )
            , ( "right", "-2px" )
            , ( "top", "-2px" )
            , ( "line-height", "2px" )
            , ( "padding", "0px" )
            ]
        , id ("elm-render-visualizer-close-button-" ++ identifier)
        ]
        [ Html.text "X"
        ]


counter : String -> Int -> Html msg
counter identifier index =
    Html.div
        [ style <|
            [ ( "list-style", "none" )
            , ( "padding", "2px" )
            , ( "font-size", "8px" )
            , ( "z-index", "20000" )
            ]
                ++ styles { radius = "50%", border = "none", inverse = True }
        , id ("elm-render-visualizer-counter-" ++ identifier)
        ]
        [ Html.text <| toString index ]


type ElmType
    = ElmFunction String
    | ElmBoolean Bool
    | ElmNumber String
    | ElmList (List ElmType)
    | ElmTuple (List ElmType)
    | ElmArray (List ElmType)
    | ElmSet (List ElmType)
    | ElmDict (List ElmType)
    | ElmRecord (List ( String, ElmType ))
    | ElmChar Char
    | ElmString String
    | ElmCustom String


entry : String -> Int -> ElmType -> Html msg
entry identifier index log =
    Html.div
        [ style
            [ ( "list-style", "none" )
            , ( "width", "400px" )
            ]
        , class "elm-render-visualizer-collapsed"
        ]
        [ Html.text (toString index)
        , renderElmType log
        ]


renderElmType : ElmType -> Html msg
renderElmType log =
    case log of
        ElmFunction name ->
            Html.text <| "Function " ++ name

        ElmBoolean bool ->
            Html.text (toString bool)

        ElmNumber num ->
            Html.text num

        ElmList xs ->
            renderListLike "[" "]" xs

        ElmTuple xs ->
            renderListLike "(" ")" xs

        ElmArray xs ->
            renderListLike "Array.fromList [" "]" xs

        ElmSet xs ->
            renderListLike "Set.fromList [" "]" xs

        ElmDict xs ->
            renderListLike "Dict.fromList [" "]" xs

        ElmRecord [] ->
            Html.text "{}"

        ElmRecord (x :: xs) ->
            Html.div
                [ style [ ( "position", "relative" ) ]
                ]
                [ Html.button
                    [ style
                        [ ( "display", "inline" )
                        , ( "position", "absolute" )
                        ]
                    , attribute "onclick" "window._elmRenderVisualizerToggleCollapse(this);"
                    ]
                    [ Html.text ">" ]
                , indentBlock <|
                    List.concat
                        [ [ renderField "{ " x ]
                        , List.map (renderField ", ") xs
                        , [ Html.text "}" ]
                        ]
                ]

        ElmChar char ->
            Html.text <| "'" ++ (String.fromChar char) ++ "'"

        ElmString string ->
            Html.text string

        ElmCustom something ->
            Html.text something


renderListLike : String -> String -> List ElmType -> Html msg
renderListLike open close items =
    case items of
        [] ->
            Html.text (open ++ close)

        x :: xs ->
            indentBlock <|
                List.concat
                    [ [ nowrap [ Html.text (open ++ " "), renderElmType x ] ]
                    , List.map (renderListItem << renderElmType) xs
                    , [ Html.text close ]
                    ]


renderList : List ElmType -> Html msg
renderList xs =
    List.map renderElmType xs
        |> List.intersperse (Html.text ", ")
        |> Html.div []


renderField : String -> ( String, ElmType ) -> Html msg
renderField prefix ( k, v ) =
    Html.div [ class "elm-render-visualizer-flex" ]
        [ Html.span [] [ Html.text (prefix ++ k ++ " = ") ]
        , renderElmType v
        ]


renderListItem : Html msg -> Html msg
renderListItem item =
    nowrap
        [ Html.text ", "
        , item
        ]


nowrap : List (Html msg) -> Html msg
nowrap =
    Html.div [ style [ ( "white-space", "nowrap" ) ] ]


indentBlock : List (Html msg) -> Html msg
indentBlock children =
    Html.div
        [ class "elm-render-visualizer-indent-block" ]
        children
