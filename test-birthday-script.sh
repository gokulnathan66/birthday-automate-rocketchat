#!/usr/bin/env bash
set -e

# Test script for birthday automation
echo "=== Birthday Automation Test Script ==="
echo

# Check if birthdays.csv exists
if [[ ! -f "birthdays.csv" ]]; then
    echo "ERROR: birthdays.csv not found!"
    exit 1
fi

echo "Found birthdays.csv file ✓"

# Display the birthdays file content
echo
echo "=== Current birthdays.csv content ==="
cat birthdays.csv
echo

# Get today's date in MM-DD format (adjust timezone as needed, IST is Asia/Kolkata)
TODAY=$(TZ=Asia/Kolkata date +%m-%d)
echo "Today's date (IST): $TODAY"
echo

# Extract matching lines (excluding header)
MATCHES=$(awk -F',' -v today="$TODAY" 'NR>1 && $2==today {print $1}' birthdays.csv)

echo "=== Birthday Check Results ==="
if [[ -n "$MATCHES" ]]; then
    echo "🎉 Birthday(s) found today!"
    echo "People celebrating: $MATCHES"
    
    MESSAGE=":tada: Birthday(s) today: $MATCHES"
    
    # Create message.json file
    cat > message.json << EOF
{
  "text": "$MESSAGE"
}
EOF
    
    echo
    echo "=== Message that would be sent ==="
    echo "Content of message.json:"
    cat message.json
    
    # Check if ROCKETCHAT_WEBHOOK is set for actual sending
    if [[ -n "$ROCKETCHAT_WEBHOOK" ]]; then
        echo
        echo "=== Sending to Rocket.Chat ==="
        echo "Webhook URL: $ROCKETCHAT_WEBHOOK"
        curl -X POST -H "Content-Type: application/json" -d @message.json $ROCKETCHAT_WEBHOOK
        echo
        echo "Message sent successfully! ✓"
        
        # Clean up message file after sending
        rm -f message.json
    else
        echo
        echo "=== Test Mode ==="
        echo "ROCKETCHAT_WEBHOOK not set - message would be sent to webhook in production"
        echo "To test with actual webhook, run:"
        echo "export ROCKETCHAT_WEBHOOK='your-webhook-url-here'"
        echo "./test-birthday-script.sh"
        echo
        echo "message.json file created for inspection."
    fi
else
    echo "No birthdays today. 😔"
    echo "Script would not send any notification."
fi

echo
echo "=== Test completed ==="