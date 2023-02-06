*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.
Library    RPA.Browser.Selenium    auto_close=${FALSE}
Library    RPA.HTTP
Library    RPA.Tables
Library    RPA.PDF
Library    RPA.Archive
    


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Download csv file
    Open the order page
    
    ${orders}=    Read csv file
    FOR    ${row}    IN    @{orders}
        Log    ${row}        
        Close the annoying modal
        Select From List By Value    head    ${row}[Head]
        select radio button    body   ${row}[Body]
        Input Text    css:input[placeholder="Enter the part number for the legs"]    ${row}[Legs]
        Input Text    address    ${row}[Address]
        Click Button    Preview
        # Click Button    Order
        Wait Until Keyword Succeeds    10x    2s    Give order
        Screenshot of the ordered robot    ${row}[Order number]
        HTML receipt as a PDF file    ${row}[Order number]
        Embeds the screenshot of the robot to the PDF receipt    ${row}[Order number]
        Click Button    order-another        
        
    END
    ZIP archive of the receipts and the images
    

*** Keywords ***
Open the order page  
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order
    # Wait Until Page Contains Element    class:btn-dark
Close the annoying modal
    Wait Until Page Contains Element    class:btn-dark
    Click Button    OK
HTML receipt as a PDF file
    [Arguments]    ${order_id}
    ${sales_results_html}=    Get Element Attribute    id:order-completion    outerHTML
    Html To Pdf    ${sales_results_html}    ${OUTPUT_DIR}${/}OUT${/}${order_id}.pdf
Screenshot of the ordered robot
    [Arguments]    ${order_id}
    Screenshot    robot-preview-image    ${OUTPUT_DIR}${/}OUT${/}${order_id}.png
Embeds the screenshot of the robot to the PDF receipt
    [Arguments]    ${order_id}
    
    ${files}=    Create List    ${OUTPUT_DIR}${/}OUT${/}${order_id}.png
    ...   ${OUTPUT_DIR}${/}OUT${/}${order_id}.pdf
    Add Files To Pdf    ${files}    ${OUTPUT_DIR}${/}OUT${/}${order_id}.pdf
ZIP archive of the receipts and the images
    Archive Folder With Zip    ${OUTPUT_DIR}${/}OUT    final_output.zip
    
    

Download csv file
    Log To Console    "Started Working............."
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=True


Read csv file        
    ${order_data}=    Read table from CSV    orders.csv    header=True
    RETURN    ${order_data}
    

Assert order done
    Wait Until Page Contains Element    id:order-another

Give order
    Click Button    Preview
    Click Button    Order
    Assert order done

