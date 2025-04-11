<?php
// Create (or open) SQLite database
$db = new SQLite3('jokes.db');

// Create table if it doesn't exist
$db->exec("CREATE TABLE IF NOT EXISTS jokes (id INTEGER PRIMARY KEY AUTOINCREMENT, joke TEXT UNIQUE, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP)");

// Function to get joke from API
function fetchJokeFromAPI() {
    $opts = [
        "http" => [
            "method" => "GET",
            "header" => "Accept: application/json\r\nUser-Agent: DadJokeFetcher/1.0 (https://example.com)\r\n"
        ]
    ];
    $context = stream_context_create($opts);
    $result = @file_get_contents("https://icanhazdadjoke.com/", false, $context);
    
    if ($result === FALSE) return false;

    $json = json_decode($result, true);
    return $json['joke'] ?? false;
}

// Try to fetch from API
$joke = fetchJokeFromAPI();
if ($joke) {
    // Store in DB if not already cached
    $stmt = $db->prepare("INSERT OR IGNORE INTO jokes (joke) VALUES (:joke)");
    $stmt->bindValue(':joke', $joke, SQLITE3_TEXT);
    $stmt->execute();
} else {
    // Fallback: get a random cached joke
    $result = $db->query("SELECT joke FROM jokes ORDER BY RANDOM() LIMIT 1");
    $row = $result->fetchArray(SQLITE3_ASSOC);
    $joke = $row['joke'] ?? 'Oops! Could not fetch a joke. Try again later.';
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Dad Joke Fetcher</title>
  <style>
    body {
      font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
      background-color: #fafafa;
      text-align: center;
      padding: 50px;
    }
    h1 {
      font-size: 2.5em;
      margin-bottom: 30px;
    }
    #joke {
      margin: 20px auto;
      padding: 20px;
      font-size: 1.4em;
      max-width: 600px;
      background-color: #fff;
      border-radius: 10px;
      box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
    }
    button {
      font-size: 1em;
      padding: 10px 20px;
      margin-top: 20px;
      background-color: #007bff;
      color: white;
      border: none;
      border-radius: 5px;
      cursor: pointer;
      transition: background-color 0.3s;
    }
    button:hover {
      background-color: #0056b3;
    }
  </style>
</head>
<body>
  <h1>Dad Joke Fetcher 🤣</h1>
  <div id="joke"><?= htmlspecialchars($joke) ?></div>
  <form method="post">
    <button type="submit">Get a Joke</button>
  </form>
</body>
</html>
