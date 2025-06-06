<?php

use Illuminate\Support\Facades\Route;
use App\Events\PrivateEvent;

Route::get("/", function () {
    return view("welcome");
});

Route::get("test", function () {
    event(new PrivateEvent("hello from websocket", 1));
    return "done";
});
