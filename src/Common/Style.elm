module Common.Style
    exposing
        ( button
        , activeButton
        , noAutocapitalize
        , noAutocorrect
        , preWrap
        , mainColumn
        , shadedColumn
        , footer
        , footerItem
        , navBar
        , myFocusStyle
        )

import Element exposing (..)
import Element.Background as Background
import Element.Font as Font
import Element.Input
import Element.Lazy
import Html.Attributes


button : List (Element.Attr () msg)
button =
    [ Background.color black, Font.color white, Element.paddingXY 10 6 ] ++ basicButtonsStyle


activeButton : Bool -> List (Element.Attr () msg)
activeButton active =
    case active of
        True ->
            activeButtonStyle

        False ->
            button


mainColumn =
    [ paddingXY 0 40, spacing 24, height (px 700) ]


shadedColumn w h =
    [ paddingXY 24 24, spacing 24, Background.color lightBlue, width w, height h ]


navBar w =
    [ spacing 24, Background.color charcoal, paddingXY 12 8, width w ]


footer =
    [ spacing 24, Background.color charcoal, paddingXY 12 8, alignBottom, width fill ]


footerItem =
    [ Font.color white ]


noAutocapitalize =
    Element.htmlAttribute (Html.Attributes.attribute "autocapitalize" "none")


noAutocorrect =
    Element.htmlAttribute (Html.Attributes.attribute "autocorrect" "off")


preWrap =
    Element.htmlAttribute (Html.Attributes.attribute "white-space" "pre-wrap")



--
-- PARAMETERS
--


buttonFontSize =
    Font.size 16


myFocusStyle =
    focusStyle { borderColor = Nothing, backgroundColor = Nothing, shadow = Nothing }



--
-- HELPERS
--


basicButtonsStyle =
    [ buttonFontSize
    , pointer
    , mouseDown [ buttonFontSize, Background.color mouseDownColor ]
    ]


activeButtonStyle : List (Element.Attr () msg)
activeButtonStyle =
    [ Background.color darkBlue, Font.color white, Element.paddingXY 10 6 ] ++ basicButtonsStyle



--
-- COLORS
--


charcoal =
    Element.rgb 0.4 0.4 0.4


grey =
    let
        g =
            0.7
    in
        Element.rgb g g g


darkRed =
    Element.rgb 0.5 0.0 0.0


white =
    Element.rgb 1 1 1


black =
    Element.rgb 0.1 0.1 0.1


mouseOverColor =
    Element.rgb 0.0 0.6 0.9


mouseDownColor =
    Element.rgb 0.7 0.1 0.1


lightBlue =
    Element.rgb 0.8 0.8 0.9


blue =
    Element.rgb 0.15 0.15 1.0


darkBlue =
    Element.rgb 0.0 0.0 0.6
