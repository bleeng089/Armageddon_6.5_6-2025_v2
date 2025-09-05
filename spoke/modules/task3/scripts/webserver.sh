#!/bin/bash
# Customized webserver installation script with member-specific customization

# Get instance name and zone
INSTANCE_NAME=$(hostname)
INSTANCE_ZONE=$(curl -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/zone | cut -d'/' -f4)

# Extract member name from instance name (handles different naming patterns)
MEMBER_NAME=$(echo $INSTANCE_NAME | grep -oE '(member[0-9]+)' || echo "member1")

# Default customization values
DEFAULT_ANNUAL_SALARY="$140,000"
DEFAULT_INFLUENCER="Theo"
DEFAULT_BACKGROUND_IMAGE="https://storage.googleapis.com/cloud-training/images/terraform/default-background.jpg"
DEFAULT_PROMO_IMAGE="https://storage.googleapis.com/cloud-training/images/terraform/default-promo.jpg"

# Try to find member customization (safe approach)
ANNUAL_SALARY=$DEFAULT_ANNUAL_SALARY
INFLUENCER=$DEFAULT_INFLUENCER
BACKGROUND_IMAGE=$DEFAULT_BACKGROUND_IMAGE
PROMO_IMAGE=$DEFAULT_PROMO_IMAGE

# If member_customizations environment variable is set, try to parse it
if [ ! -z "$member_customizations" ]; then
    # Use python for more robust JSON parsing
    CUSTOMIZATION=$(python3 -c "
import json, os
try:
    customizations = json.loads(os.environ['member_customizations'])
    for member in customizations:
        if member.get('name') == '$MEMBER_NAME':
            print(f\"{member.get('annual_salary', '$DEFAULT_ANNUAL_SALARY')}|{member.get('influencer', '$DEFAULT_INFLUENCER')}|{member.get('background_image_url', '$DEFAULT_BACKGROUND_IMAGE')}|{member.get('promo_image_url', '$DEFAULT_PROMO_IMAGE')}\")
            break
except:
    pass
")

    if [ ! -z "$CUSTOMIZATION" ]; then
        IFS='|' read -r CUSTOM_SALARY CUSTOM_INFLUENCER CUSTOM_BACKGROUND CUSTOM_PROMO <<< "$CUSTOMIZATION"
        ANNUAL_SALARY=$CUSTOM_SALARY
        INFLUENCER=$CUSTOM_INFLUENCER
        BACKGROUND_IMAGE=$CUSTOM_BACKGROUND
        PROMO_IMAGE=$CUSTOM_PROMO
    fi
fi

# Update and install required packages
apt-get update
apt-get install -y nginx unzip wget python3

# Create web directory
mkdir -p /var/www/html

# Download and set background image with error handling
wget -O /tmp/background.jpg "$BACKGROUND_IMAGE" || cp /dev/null /tmp/background.jpg
wget -O /tmp/promo.jpg "$PROMO_IMAGE" || cp /dev/null /tmp/promo.jpg

# Create customized HTML page with improved styling
cat > /var/www/html/index.html << EOF
<!DOCTYPE html>
<html>
<head>
    <title>${MEMBER_NAME}'s Server</title>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Roboto+Mono:wght@400;700&display=swap');
        
        body {
            font-family: 'Roboto Mono', monospace;
            background: url('/background.jpg') no-repeat center center fixed;
            background-size: cover;
            margin: 0;
            padding: 20px;
            color: #333;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
        }
        
        .resource-info {
            position: absolute;
            top: 10px;
            left: 10px;
            background: rgba(255, 255, 255, 0.95);
            padding: 15px;
            border-radius: 8px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
            border: 1px solid #e0e0e0;
            max-width: 300px;
        }
        
        .resource-info h3 {
            margin: 0 0 10px 0;
            color: #2c5282;
            font-size: 16px;
        }
        
        .resource-info p {
            margin: 5px 0;
            font-size: 14px;
        }
        
        .resource-info strong {
            color: #4a5568;
        }
        
        .content-container {
            text-align: center;
            background: rgba(255, 255, 255, 0.95);
            padding: 30px;
            border-radius: 12px;
            box-shadow: 0 8px 25px rgba(0,0,0,0.15);
            max-width: 800px;
            margin: 20px;
        }
        
        .promo-image {
            max-width: 100%;
            max-height: 400px;
            border: 8px solid #fff;
            box-shadow: 0 6px 20px rgba(0,0,0,0.2);
            border-radius: 8px;
            margin: 20px 0;
        }
        
        .success-statement {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 25px;
            border-radius: 10px;
            text-align: center;
            margin: 25px 0;
            font-size: 1.3em;
            font-weight: bold;
            box-shadow: 0 5px 15px rgba(0,0,0,0.2);
        }
        
        .header {
            font-size: 2.5em;
            color: #2d3748;
            margin-bottom: 20px;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.1);
        }
        
        .footer {
            margin-top: 30px;
            font-size: 0.9em;
            color: #718096;
        }
    </style>
</head>
<body>
    <div class="resource-info">
        <h3>Instance Information</h3>
        <p><strong>Name:</strong> ${INSTANCE_NAME}</p>
        <p><strong>Zone:</strong> ${INSTANCE_ZONE}</p>
        <p><strong>Member:</strong> ${MEMBER_NAME}</p>
        <p><strong>Status:</strong> ✅ Running</p>
    </div>
    
    <div class="content-container">
        <div class="header">🚀 Welcome to ${MEMBER_NAME}'s Server</div>
        
        <div class="promo-container">
            <img src="/promo.jpg" alt="Promotional Material" class="promo-image" onerror="this.style.display='none'">
        </div>
        
        <div class="success-statement">
            💫 I, ${MEMBER_NAME}, will make ${ANNUAL_SALARY} per year thanks to Theo and ${INFLUENCER}!
        </div>
        
        <div class="footer">
            Served from: ${INSTANCE_NAME} | ${INSTANCE_ZONE}
        </div>
    </div>
</body>
</html>
EOF

# Copy images to web directory (with fallback)
cp /tmp/background.jpg /var/www/html/ || true
cp /tmp/promo.jpg /var/www/html/ || true

# Create a simple fallback image if downloads failed
if [ ! -f /var/www/html/background.jpg ]; then
    convert -size 800x600 gradient:#667eea-#764ba2 /var/www/html/background.jpg 2>/dev/null || \
    echo "background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);" > /var/www/html/background.css
fi

if [ ! -f /var/www/html/promo.jpg ]; then
    convert -size 400x300 label:"${MEMBER_NAME}\nSuccess Story" /var/www/html/promo.jpg 2>/dev/null || \
    echo "/* Fallback promo image */" > /var/www/html/promo.css
fi

# Set proper permissions
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

# Start and enable nginx
systemctl stop apache2 2>/dev/null || true  # Ensure no conflicts
systemctl start nginx
systemctl enable nginx

# Test the web server
curl -s http://localhost > /dev/null && echo "Web server setup completed successfully!" || echo "Web server setup completed with warnings."

# Add some logging
echo "$(date): Web server setup completed for $MEMBER_NAME" >> /var/log/webserver-setup.log