#!/bin/bash
# Update system and install httpd (Apache)
sudo yum update -y
sudo yum install -y httpd
# Start httpd service and enable it to start on boot
sudo systemctl start httpd
sudo systemctl enable httpd

# Fetch metadata using IMDSv2
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)
AMI_ID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/ami-id)
INSTANCE_TYPE=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-type)
PUBLIC_IP=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/public-ipv4)
HOSTNAME=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/hostname)

# Create a web page to display the metadata
sudo cat <<EOF > /var/www/html/index.html
#!/bin/bash
# Update system and install httpd (Apache)
sudo yum update -y
sudo yum install -y httpd
# Start httpd service and enable it to start on boot
sudo systemctl start httpd
sudo systemctl enable httpd

# Fetch metadata using IMDSv2
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)
AMI_ID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/ami-id)
INSTANCE_TYPE=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-type)
PUBLIC_IP=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/public-ipv4)
HOSTNAME=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/hostname)

# Create a web page to display the metadata
sudo cat <<EOF > /var/www/html/index.html
<html lang="en">
<head>
<meta charset="utf-8" />
<meta name="viewport" content="width=device-width, initial-scale=1" />
<title>AWS Cloud Club @ Sheridan</title>
<style>
:root{
  /* AWS Inspired Palette */
  --bg: #232f3e; /* AWS Deep Squid Ink */
  --accent: #ff9900; /* AWS Orange */
  --cloud: #0073bb; /* AWS Blue */
  --ink: #ffffff;
  --ink2: #f2f2f2;
  --card: rgba(255, 255, 255, 0.08);
  --card-b: rgba(255, 255, 255, 0.15);
}
*{box-sizing:border-box} html,body{height:100%}
body{
  margin:0; background: var(--bg); color: var(--ink);
  font: 16px/1.45 system-ui, -apple-system, Segoe UI, Roboto, Helvetica, Arial;
  -webkit-font-smoothing: antialiased; -moz-osx-font-smoothing: grayscale; overflow-x: hidden;
}
header{position:relative; max-width:1100px; margin:40px auto 0; padding:24px clamp(16px, 4vw, 28px)}
.ribbon{
  display:inline-flex; gap:10px; align-items:center; padding:8px 16px; border-radius:999px;
  border:1px solid rgba(255,255,255,.1); background:rgba(255,255,255,.05);
  backdrop-filter:blur(10px); -webkit-backdrop-filter:blur(10px)
}
.small{font-weight:800; letter-spacing:1px; font-size:12px; text-transform:uppercase; color: var(--accent)}
.title{
  margin:18px 0 8px; font-size:clamp(32px, 5vw, 58px); font-weight:900; line-height:1.1; letter-spacing:-.03em;
  background: linear-gradient(135deg, #fff 30%, var(--cloud)); -webkit-background-clip: text; background-clip: text; color: transparent;
  filter: drop-shadow(0 10px 20px rgba(0,0,0,0.3));
}
.underline{
  height:4px; width: 120px; border-radius:999px; background: var(--accent);
  box-shadow: 0 0 15px var(--accent); margin-bottom: 20px;
}
.subtitle{margin:10px 0 0; font-size:clamp(16px, 2.2vw, 20px); color: var(--ink2); opacity: 0.9}

/* Background Visual Effects */
.bgfx{position:fixed; inset:0; pointer-events:none; z-index:0}
.bgfx::before{
  content:""; position:absolute; top:-10%; right:-10%; width: 50%; height: 50%;
  background: radial-gradient(circle, rgba(0,115,187,0.3) 0%, transparent 70%);
  filter: blur(60px);
}
.bgfx::after{
  content:""; position:absolute; bottom:-10%; left:-10%; width: 40%; height: 40%;
  background: radial-gradient(circle, rgba(255,153,0,0.15) 0%, transparent 70%);
  filter: blur(60px); animation: float 12s ease-in-out infinite alternate;
}
@keyframes float{ to{transform:translateY(5%) translateX(5%)} }

.stage{position:relative; z-index:1; max-width:1100px; margin:20px auto 80px; padding:0 clamp(16px, 4vw, 28px);
  display:grid; gap:24px; grid-template-columns: 1.2fr 0.8fr}
@media (max-width:920px){.stage{grid-template-columns:1fr}}

.card{
  position:relative; padding:clamp(20px, 3vw, 30px); border-radius:24px; background: var(--card); border: 1px solid var(--card-b);
  backdrop-filter: blur(16px); -webkit-backdrop-filter: blur(16px);
  box-shadow: 0 20px 40px rgba(0,0,0,0.4); transition: transform 0.3s ease;
}
.card h2{margin:0 0 20px; font-size:22px; color: var(--accent); border-bottom: 1px solid rgba(255,255,255,0.1); padding-bottom: 10px}
.meta{display:grid; grid-template-columns: max-content 1fr; gap:16px 20px; font-size:15px}
.k{font-weight:700; color: var(--cloud); text-transform: uppercase; font-size: 12px; letter-spacing: 0.5px}
.v{font-weight:500; color: #fff; word-break:break-word}
.chip{
  display:inline-flex; align-items:center; padding:4px 12px; border-radius:8px;
  background: rgba(0, 115, 187, 0.2); border: 1px solid var(--cloud); font-size: 13px;
}
.cta{margin-top:24px; display:flex; gap:12px; flex-wrap:wrap}
.btn{
  appearance:none; border:0; cursor:pointer; padding:12px 20px; border-radius:12px;
  font-weight:700; text-decoration:none; display:inline-block; transition: 0.2s;
}
.primary{background: var(--accent); color: #000}
.primary:hover{background: #e68a00; transform: translateY(-2px)}
.ghost{background: transparent; border: 1px solid rgba(255,255,255,0.3); color: #fff}
.ghost:hover{background: rgba(255,255,255,0.1)}

footer{max-width:1100px; margin:0 auto 40px; padding:0 clamp(16px, 4vw, 28px); font-size:13px; opacity: 0.6}

@media (prefers-reduced-motion:reduce){ .bgfx::after{animation:none!important} }
</style>
</head>
<body>
<div class="bgfx" aria-hidden="true"></div>

<header>
  <div class="ribbon"><span class="small">Sheridan College</span></div>
  <h1 class="title">Welcome to AWS Cloud Club Event @ Sheridan</h1>
  <div class="underline"></div>
  <p class="subtitle">Cloud architecture, live deployments, and student innovation.</p>
</header>

<main class="stage">
  <section class="card tilt">
    <h2>AWS Session</h2>
    <div class="meta">
      <div class="k">Topic</div><div class="v">Building Resilient Systems with AWS Auto Scaling & Load Balancing</div>
      <div class="k">Instance</div><div class="v"><span class="chip">Node: <strong>$HOSTNAME</strong></span></div>
      <div class="k">Public IP</div><div class="v" style="color:var(--accent)"><strong>$PUBLIC_IP</strong></div>
      <div class="k">Status</div><div class="v">Live Demo Environment</div>
      <div class="k">Location</div><div class="v">Sheridan College - Brampton/Oakville</div>
    </div>

    <div class="cta">
      <a class="btn primary" href="https://amazon.com" target="_blank">Explore AWS Free Tier</a>
      <a class="btn ghost" href="https://amazon.com" target="_blank">Learning Path</a>
    </div>
  </section>

  <!-- More Hands-On Resources -->
  <aside class="card tilt">
    <h2>💻 More Hands-On</h2>
    <p style="color: #ccc; line-height: 1.6;">For more practical labs, exercises, and hands-on tutorials, check here:</p>
    <a class="btn primary" href="https://hiroko.io/aws/" target="_blank">
      📚 AWS Hands-On Resources
    </a>
    <div class="chip" style="margin-top: 20px; border-color: var(--accent); color: var(--accent); width: 100%; justify-content: center;">Student Led • AWS Powered</div>
  </aside>
</main>

<footer>
  <div>&copy; 2026 AWS Cloud Club at Sheridan College</div>
</footer>

<script>
// Subtle 3D Tilt effect
addEventListener('mousemove', e => {
  const x = (e.clientX / innerWidth - 0.5) * 4;
  const y = (e.clientY / innerHeight - 0.5) * -4;
  document.querySelectorAll('.tilt').forEach(el => {
    el.style.transform = `perspective(1000px) rotateX(${y}deg) rotateY(${x}deg)`;
  });
}, {passive: true});
</script>
</body>
</html>
EOF
