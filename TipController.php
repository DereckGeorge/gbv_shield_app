<?php

namespace App\Http\Controllers;

use App\Models\Tip;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Validator;
use Carbon\Carbon;

/**
 * @OA\Tag(
 *     name="Tips",
 *     description="API Endpoints for managing tips"
 * )
 */
class TipController extends Controller
{
    /**
     * @OA\Get(
     *     path="/api/tips",
     *     summary="Get all tips with their like counts",
     *     tags={"Tips"},
     *     @OA\Response(
     *         response=200,
     *         description="List of all tips",
     *         @OA\JsonContent(
     *             type="array",
     *             @OA\Items(ref="#/components/schemas/Tip")
     *         )
     *     )
     * )
     */
    public function index()
    {
        $tips = Tip::orderBy('created_at', 'desc')->get();
        return response()->json($tips);
    }

    /**
     * @OA\Get(
     *     path="/api/tips/today",
     *     summary="Get tip of the day",
     *     tags={"Tips"},
     *     @OA\Response(
     *         response=200,
     *         description="Random tip that changes every 24 hours",
     *         @OA\JsonContent(ref="#/components/schemas/Tip")
     *     )
     * )
     */
    public function tipOfTheDay()
    {
        $today = Carbon::now()->format('Y-m-d');
        
        // Get or set the tip ID for today
        $tipId = Cache::remember('tip_of_the_day_id_' . $today, Carbon::now()->endOfDay(), function () {
            $tip = Tip::inRandomOrder()->first();
            return $tip ? $tip->id : null;
        });

        if (!$tipId) {
            return response()->json(['message' => 'No tips available'], 404);
        }

        // Always get a fresh copy of the tip with its relationships
        $tip = Tip::withCount('likes')
            ->with('likes')
            ->findOrFail($tipId);

        return response()->json($tip->fresh());
    }

    /**
     * @OA\Post(
     *     path="/api/tips",
     *     summary="Create a new tip (Admin only)",
     *     tags={"Tips"},
     *     security={{"bearerAuth":{}}},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             required={"title", "content"},
     *             @OA\Property(property="title", type="string"),
     *             @OA\Property(property="content", type="string")
     *         )
     *     ),
     *     @OA\Response(
     *         response=201,
     *         description="Tip created successfully",
     *         @OA\JsonContent(ref="#/components/schemas/Tip")
     *     ),
     *     @OA\Response(
     *         response=403,
     *         description="Unauthorized - Admin access required"
     *     )
     * )
     */
    public function store(Request $request)
    {
        if (!auth()->user() || auth()->user()->role !== 'admin') {
            return response()->json(['message' => 'Unauthorized. Admin access required.'], 403);
        }

        $validator = Validator::make($request->all(), [
            'title' => 'required|string|max:255',
            'content' => 'required|string'
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $tip = Tip::create($request->all());

        return response()->json([
            'message' => 'Tip created successfully',
            'tip' => $tip
        ], 201);
    }

    /**
     * @OA\Put(
     *     path="/api/tips/{id}",
     *     summary="Update a tip (Admin only)",
     *     tags={"Tips"},
     *     security={{"bearerAuth":{}}},
     *     @OA\Parameter(
     *         name="id",
     *         in="path",
     *         required=true,
     *         @OA\Schema(type="string", format="uuid")
     *     ),
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             @OA\Property(property="title", type="string"),
     *             @OA\Property(property="content", type="string")
     *         )
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Tip updated successfully",
     *         @OA\JsonContent(ref="#/components/schemas/Tip")
     *     ),
     *     @OA\Response(
     *         response=403,
     *         description="Unauthorized - Admin access required"
     *     ),
     *     @OA\Response(
     *         response=404,
     *         description="Tip not found"
     *     )
     * )
     */
    public function update(Request $request, $id)
    {
        if (!auth()->user() || auth()->user()->role !== 'admin') {
            return response()->json(['message' => 'Unauthorized. Admin access required.'], 403);
        }

        $validator = Validator::make($request->all(), [
            'title' => 'required|string|max:255',
            'content' => 'required|string'
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $tip = Tip::findOrFail($id);
        $tip->update($request->all());

        // Clear tip of the day cache if this tip was cached
        if (Cache::has('tip_of_the_day')) {
            $cachedTip = Cache::get('tip_of_the_day');
            if ($cachedTip && $cachedTip->id === $tip->id) {
                Cache::forget('tip_of_the_day');
            }
        }

        return response()->json([
            'message' => 'Tip updated successfully',
            'tip' => $tip
        ]);
    }

    /**
     * @OA\Delete(
     *     path="/api/tips/{id}",
     *     summary="Delete a tip (Admin only)",
     *     tags={"Tips"},
     *     security={{"bearerAuth":{}}},
     *     @OA\Parameter(
     *         name="id",
     *         in="path",
     *         required=true,
     *         @OA\Schema(type="string", format="uuid")
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Tip deleted successfully"
     *     ),
     *     @OA\Response(
     *         response=403,
     *         description="Unauthorized - Admin access required"
     *     ),
     *     @OA\Response(
     *         response=404,
     *         description="Tip not found"
     *     )
     * )
     */
    public function destroy($id)
    {
        if (!auth()->user() || auth()->user()->role !== 'admin') {
            return response()->json(['message' => 'Unauthorized. Admin access required.'], 403);
        }

        $tip = Tip::findOrFail($id);

        // Clear tip of the day cache if this tip was cached
        if (Cache::has('tip_of_the_day')) {
            $cachedTip = Cache::get('tip_of_the_day');
            if ($cachedTip && $cachedTip->id === $tip->id) {
                Cache::forget('tip_of_the_day');
            }
        }

        $tip->delete();

        return response()->json([
            'message' => 'Tip deleted successfully'
        ]);
    }

    /**
     * @OA\Post(
     *     path="/api/tips/{id}/like",
     *     summary="Like or unlike a tip",
     *     tags={"Tips"},
     *     security={{"bearerAuth":{}}},
     *     @OA\Parameter(
     *         name="id",
     *         in="path",
     *         required=true,
     *         @OA\Schema(type="string", format="uuid")
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Like status toggled successfully",
     *         @OA\JsonContent(
     *             @OA\Property(property="message", type="string"),
     *             @OA\Property(property="is_liked", type="boolean"),
     *             @OA\Property(property="likes_count", type="integer")
     *         )
     *     )
     * )
     */
    public function toggleLike($id)
    {
        $tip = Tip::findOrFail($id);
        $user = auth()->user();

        if ($tip->likes()->where('user_id', $user->id)->exists()) {
            $tip->likes()->detach($user->id);
            $tip->decrement('likes_count');
            $isLiked = false;
        } else {
            $tip->likes()->attach($user->id);
            $tip->increment('likes_count');
            $isLiked = true;
        }

        return response()->json([
            'message' => $isLiked ? 'Tip liked successfully' : 'Tip unliked successfully',
            'is_liked' => $isLiked,
            'likes_count' => $tip->likes_count
        ]);
    }
} 