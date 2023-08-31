*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.
...                 Saves the order HTML receipt as a PDF file.
...                 Saves the screenshot of the ordered robot.
...                 Embeds the screenshot of the robot to the PDF receipt.
...                 Creates ZIP archive of the receipts and the images.

Library             RPA.Browser.Selenium    auto_close=${True}
Library             RPA.HTTP
Library             RPA.Tables
Library             RPA.PDF
Library             RPA.Archive


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot order website
    ${orders}=    Get orders
    FOR    ${order}    IN    @{orders}
        Close the annoying modal
        Fill the form    ${order}
        Preview robot
        ${screenshot} =    Take screenshot of image    ${order}[Order number]
        Wait Until Keyword Succeeds    5x    0.5 sec    Submit order
        Collect the results    ${order}[Order number]    ${screenshot}
        Order another robot
    END
    Archive output PDFs
    [Teardown] Close Browser
    

*** Keywords ***
Open the robot order website
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order

Get orders
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=True
    ${my_Table}=    Read table from CSV    orders.csv    header=True
    RETURN    ${my_Table}

Close the annoying modal
    Click Element If Visible    //*[@class="btn btn-dark"]
    Wait Until Element Is Not Visible    //*[@id="modal-content"]

Fill the form
    [Arguments]    ${order}
    Wait Until Element Is Enabled    head
    Select From List By Value    head    ${order}[Head]
    Select Radio Button    body    ${order}[Body]
    Input Text    //*[@placeholder="Enter the part number for the legs"]    ${order}[Legs]
    Input Text    address    ${order}[Address]

Save order as PDF
    [Arguments]    ${order_number}
    ${receiptAsHtml} =    Get Element Attribute    id:receipt    outerHTML
    Set Local Variable    ${file_path}     ${CURDIR}${/}output${/}receipts${/}receipt_${order_number}.pdf
    Html To Pdf    ${receiptAsHtml}    ${file_path}
    RETURN    ${file_path}

Store screenshot and pdf together
    [Arguments]    ${screenshot}    ${pdf}
    Open Pdf    ${pdf}
    ${screenShot_Files} =    Create List    ${screenshot}
    Add Files To Pdf     ${screenShot_Files}    ${pdf}    append=${True}
    Close Pdf    ${pdf}

Collect the results
    [Arguments]    ${order_number}    ${screenshot}
    ${pdf} =    Save order as PDF    ${order_number}
    Store screenshot and pdf together    ${screenshot}    ${pdf}

Store the receipt as a PDF file
    [Arguments]    ${pdfName}
    Wait Until Element Is Visible    id:receipt
    ${pdfContent}=    Get Element Attribute    id:receipt    outerHTML


Preview robot
    Click Button When Visible    //*[@id="preview"]
    Wait Until Element Is Visible    id=robot-preview-image


Take screenshot of image
    [Arguments]    ${order_number}
    Set Local Variable    ${file_path}    ${CURDIR}${/}output${/}screenshots${/}robot_preview_image_${order_number}.png
    Screenshot    //*[@id="robot-preview-image"]    ${file_path}
    RETURN    ${file_path}

Submit order
    Click Button    //*[@id="order"]
    Wait Until Element Is Visible    //*[@id="receipt"]
    Wait Until Element Is Visible    //*[@id="order-another"]


Order another robot
    Click Button    id=order-another
    Wait Until Element Is Visible    id=order


Archive output PDFs
    ${zip_output_name} =    Set Variable    ${CURDIR}${/}output${/}receipts.zip
    Archive Folder With Zip    ${CURDIR}${/}output${/}receipts    ${zip_output_name}

[Teardown] Close Browser
    Close Browser